import type { Metadata } from "next";
import Script from "next/script";
import { ThemeToggle } from "@/components/theme-toggle";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Varnamala Admin",
    template: "%s · Varnamala Admin",
  },
  description: "Review, improve, and release Varnamala language courses.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="h-full antialiased" suppressHydrationWarning>
      <body className="min-h-full">
        {children}
        <ThemeToggle />
      </body>
      <Script id="varnamala-theme" strategy="beforeInteractive">
        {`try{const saved=localStorage.getItem("varnamala-theme");document.documentElement.dataset.theme=saved==="light"||saved==="dark"?saved:(matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light")}catch{document.documentElement.dataset.theme="light"}`}
      </Script>
    </html>
  );
}
