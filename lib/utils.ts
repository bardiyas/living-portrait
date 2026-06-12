/** Tiny className joiner. Swap for clsx/tailwind-merge if the project grows. */
export function cn(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}
