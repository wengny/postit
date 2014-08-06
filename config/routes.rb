PostitTemplate::Application.routes.draw do
  root to: 'posts#index'

  # get '/posts', to: 'posts#index'
  # get '/posts/:id', to: 'posts#show'
  # get '/posts/new', to: 'posts#new'
  # post '/posts', to: 'posts#create'
  # get '/posts/:id/edit', to: 'psosts#edit'
  # patch '/posts/:id', to: 'posts#update'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/register', to: 'users#new'


  resources :posts, except: [:destroy] do
    member do  
      post 'vote'  #POST /posts/3/vote
    end

    resources :comments, only: [:create] do
      member do
        post 'vote' # POST /posts/3/comments/3/vote =>comments#vote
      end
    end
  end

  resources :categories, only: [:new, :show, :create]
  resources :users, only: [:show, :create, :edit, :update]

  
end

# POST /POSTS/3/COMMENTS/3/vote comments#vote