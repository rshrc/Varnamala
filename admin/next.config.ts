import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  poweredByHeader: false,
  reactStrictMode: true,
  turbopack: { root: process.cwd() },
};

export default nextConfig;
