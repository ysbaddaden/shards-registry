require "frost/routing/mapper"

Frost::Routing.draw do
  get "/", "pages#landing", as: "root"

  resources :shards, except: %i(edit update replace) do
    collection do
      get :search, as: "search_shards"
    end

    member do
      post :refresh, as: "refresh_shard"
    end

    resources :versions, only: %i(index)
  end

  resources :users, except: %i(index replace) do
    collection do
      resource :session, only: %i(new create destroy)
    end

    member do
      post "/api_key/reset", "users#reset_api_key", as: "reset_api_key"
    end
  end

  namespace :api do
    resources :users, only: %i(create update) do
      collection do
        get :api_key
      end
    end

    resources :shards, only: %i(show create destroy) do
      collection do
        get :search
      end

      resources :versions, only: %i(index) do
        collection do
          get :latest
        end
      end
    end

    scope path: "webhooks", controller: "webhooks" do
      post :github, as: "github_webhook"
    end
  end
end
