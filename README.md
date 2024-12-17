# PhoenixSvelteSpa

## WARN

If you using this repository as template, remember to change **signing_salt** of [@session_options](blob/master/lib/phoenix_svelte_spa_web/endpoint.ex#L10) and [live_view config](blob/master/config/config.exs#L22)!

## Phoenix

```shell
mix phx.new phoenix_svelte_spa --no-assets --no-ecto --no-gettext --no-html --no-live --no-mailer
cd phoenix_svelte_spa
mix phx.server
```

### mix.exs

```elixir
defp aliases do
  [
    setup: ["deps.get", ~s|run -e 'System.cmd("pnpm", ["install"], cd: "web")'|],
    "web.deploy": [~s|run -e 'System.cmd("pnpm", ["build"], cd: "web")'|]
  ]
end
```

### config/prod.exs

```elixir
import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix web.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :phoenix_svelte_spa, PhoenixSvelteSpaWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"
```

### lib/phoenix_svelte_spa_web.ex

```elixir
def static_paths, do: ~w(index.html _app favicon.png robots.txt)
```

### lib/phoenix_svelte_spa_web/router.ex

```elixir
defmodule PhoenixSvelteSpaWeb.Router do
  use PhoenixSvelteSpaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PhoenixSvelteSpaWeb do
    pipe_through :api
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:phoenix_svelte_spa, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PhoenixSvelteSpaWeb.Telemetry
    end
  end

  scope "/", PhoenixSvelteSpaWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end
```

### lib/phoenix_svelte_spa_web/controllers/page_controller.ex

```elixir
defmodule PhoenixSvelteSpaWeb.PageController do
  use PhoenixSvelteSpaWeb, :controller

  def index(conn, _params) do
    index_path = Path.join(:code.priv_dir(:phoenix_svelte_spa), "static/index.html")

    conn
    |> put_resp_header("content-type", "text/html")
    |> send_file(200, index_path)
  end
end
```

### .gitignore

```
...
# Ignore assets that are produced by build tools.
/priv/static/
```

## SvelteKit

```shell
pnpx sv create web
cd web
```

### web/package.json

```json
{
  ...
  "devDependencies": {
    "@sveltejs/adapter-static": "^3.0.6",
	...
  }
}
```

```shell
pnpm i
```

### web/svelte.config.js

```javascript
import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: vitePreprocess(),

	kit: {
		adapter: adapter({ pages: '../priv/static' })
	}
};

export default config;
```

### web/vite.config.ts

```typescript
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [sveltekit()],
	server: {
		proxy: {
			'/api': {
				target: 'http://localhost:4000',
				changeOrigin: true
			}
		}
	}
});
```

### web/src/routes/+layout.ts

```typescript
export const prerender = true;
export const ssr = false;
```

### build

```shell
pnpm i
pnpm build
cd ..
```

## Run

```shell
mix phx.server
```

Access: http://localhost:4000 .
