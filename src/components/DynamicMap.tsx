import dynamic from 'next/dynamic';

export const DynamicMap = dynamic(() => import('./Map'), { 
  ssr: false,
  loading: () => <div className="w-full h-full min-h-[300px] bg-card/20 animate-pulse flex items-center justify-center text-muted-foreground">Loading Map...</div>
});
