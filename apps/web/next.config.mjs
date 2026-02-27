/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    transpilePackages: ['@bountypool/shared', '@bountypool/base-adapter', '@bountypool/stacks-adapter'],
};

export default nextConfig;
