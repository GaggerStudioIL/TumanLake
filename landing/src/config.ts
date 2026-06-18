const env = import.meta.env;

const withFallback = (value: string | undefined, fallback = "#zbt") =>
  value && value.trim().length > 0 ? value : fallback;

export const links = {
  apk: withFallback(env.NEXT_PUBLIC_APK_URL),
  telegram: withFallback(env.NEXT_PUBLIC_TELEGRAM_URL),
  bugReport: withFallback(env.NEXT_PUBLIC_BUG_REPORT_URL),
  vk: withFallback(env.NEXT_PUBLIC_VK_URL),
  youtube: withFallback(env.NEXT_PUBLIC_YOUTUBE_URL),
  privacy: withFallback(env.NEXT_PUBLIC_PRIVACY_URL),
};

export const externalLinkProps = (href: string) => {
  const isExternal = /^https?:\/\//i.test(href);

  return {
    href,
    target: isExternal ? "_blank" : undefined,
    rel: isExternal ? "noreferrer" : undefined,
  };
};
