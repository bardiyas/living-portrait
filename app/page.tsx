import { LivingPortrait } from "@/components/portrait/LivingPortrait";

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen max-w-2xl flex-col items-center justify-center gap-6 px-6">
      <LivingPortrait />
      <p className="text-sm text-neutral-500">
        A living portrait — what you see depends on the hour.
      </p>
    </main>
  );
}
