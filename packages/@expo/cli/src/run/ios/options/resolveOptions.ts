import { getConfig } from '@expo/config';

import { isSimulatorDevice, resolveDeviceAsync } from './resolveDevice';
import { resolveNativeSchemePropsAsync } from './resolveNativeScheme';
import { resolveXcodeProject } from './resolveXcodeProject';
import { isOSType } from '../../../start/platforms/ios/simctl';
import { profile } from '../../../utils/profile';
import { resolveRemoteBuildCacheProvider } from '../../../utils/remote-build-cache-providers';
import { resolveBundlerPropsAsync } from '../../resolveBundlerProps';
import { BuildProps, Options } from '../XcodeBuild.types';

/** Resolve arguments for the `run:ios` command. */
export async function resolveOptionsAsync(
  projectRoot: string,
  options: Options
): Promise<BuildProps> {
  const xcodeProject = resolveXcodeProject(projectRoot);

  const bundlerProps = await resolveBundlerPropsAsync(projectRoot, options);

  // Resolve the scheme before the device so we can filter devices based on
  // whichever scheme is selected (i.e. don't present TV devices if the scheme cannot be run on a TV).
  const { osType, name: scheme } = await resolveNativeSchemePropsAsync(
    projectRoot,
    options,
    xcodeProject
  );

  // Use the configuration or `Debug` if none is provided.
  const configuration = options.configuration || 'Debug';

  // Resolve the device based on the provided device id or prompt
  // from a list of devices (connected or simulated) that are filtered by the scheme.
  const device = await profile(resolveDeviceAsync)(options.device, {
    // It's unclear if there's any value to asserting that we haven't hardcoded the os type in the CLI.
    osType: isOSType(osType) ? osType : undefined,
    xcodeProject,
    scheme,
    configuration,
  });

  const isSimulator = isSimulatorDevice(device);

  const projectConfig = getConfig(projectRoot);
  const buildCacheProvider = resolveRemoteBuildCacheProvider(
    projectConfig.exp.experiments?.remoteBuildCache?.provider,
    projectRoot
  );

  // This optimization skips resetting the Metro cache needlessly.
  // The cache is reset in `../node_modules/react-native/scripts/react-native-xcode.sh` when the
  // project is running in Debug and built onto a physical device. It seems that this is done because
  // the script is run from Xcode and unaware of the CLI instance.
  const shouldSkipInitialBundling = configuration === 'Debug' && !isSimulator;

  return {
    ...bundlerProps,
    shouldStartBundler: options.configuration === 'Debug' || bundlerProps.shouldStartBundler,
    projectRoot,
    isSimulator,
    xcodeProject,
    device,
    configuration,
    shouldSkipInitialBundling,
    buildCache: options.buildCache !== false,
    scheme,
    buildCacheProvider,
  };
}
