import type { FC, PropsWithChildren } from "hono/jsx";

export interface LayoutProps {
  title: string;
  shortTitle?: string | null;
  url?: string | null;
  description?: string | null;
  imageUrl?: string | null;
}

export const Layout: FC<PropsWithChildren<LayoutProps>> = (props) => {
  return <main>{props.children}</main>;
};

export default Layout;
