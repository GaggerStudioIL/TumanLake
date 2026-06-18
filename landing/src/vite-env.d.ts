/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly NEXT_PUBLIC_APK_URL?: string;
  readonly NEXT_PUBLIC_TELEGRAM_URL?: string;
  readonly NEXT_PUBLIC_BUG_REPORT_URL?: string;
  readonly NEXT_PUBLIC_VK_URL?: string;
  readonly NEXT_PUBLIC_YOUTUBE_URL?: string;
  readonly NEXT_PUBLIC_PRIVACY_URL?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
