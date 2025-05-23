'use client';
import React from 'react';
import { Text } from 'react-native';

import { renderPage } from '../components/server-actions';

export default function ServerActionTest() {
  // Test hooks to ensure they don't break the export.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [isLoading, setLoading] = React.useState(true);

  const memo = React.useMemo(() => renderPage({ title: 'Hello!' }), []);
  return <React.Suspense fallback={<Text>Loading...</Text>}>{memo}</React.Suspense>;
}
