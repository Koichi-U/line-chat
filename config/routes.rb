Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # resources :lineevents

  # Defines the root path route ("/")
  root "users#admin"
  get '/admin' => 'users#admin'
  post '/callback' => 'lineevents#callback'
  get '/line/users' => 'lineevents#list'
  get '/line/chat/:userid' => 'lineevents#chat', as: 'chat'
  post '/line/post' => 'lineevents#messagecreate'
end
