Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get '/home', to: 'application#home'
  get '/home_jwt', to: 'application#home_jwt'
  get '/admin', to: 'application#admin'
  post '/login', to: 'application#login'
  post '/login_jwt',to: 'application#login_jwt' 
  post '/logout', to: 'application#logout'

end
