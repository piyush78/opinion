Rails.application.routes.draw do

  resources :charges
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'users#login'
  match 'users/signup' => 'users#signup', :via => [:get, :post]


  match 'users/signin' => 'users#signin',via: [:get , :post]

  get 'users/signout' => 'users#signout'
  #delete 'logout' => 'destroy_user_session'
  get 'subscribe' => 'pages#subscribe'
  post 'users/forgetpassword' => 'users#forgetpassword'
  get 'users/subscribe' => 'users#subscribe'
  get '/conversations' => 'messages#conversations'
  get '/sentconversations' => 'messages#sentconversations'
  get 'users/newuser' => 'users#newuser'
  get 'users/login' => 'users#login'
  get 'users/changepassword' => 'users#changepassword'
  get 'users/resetpassword' => 'users#resetpassword'
  post 'comments/create' => 'comments#create'
  get 'messages/edit' => 'messages#edit'
  get '/users' => 'users#index'
  get  'messages' => 'messages#new'
  post 'messages/update' => 'messages#update'
  get 'messages/show' => 'messages#show'
  get 'messages/sentshow' => 'messages#sentshow'
  post 'messages/create' => 'messages#create'
  get 'messages/delete' => 'messages#delete'
  get 'messages/deletesent' => 'messages#deletesent'
  get 'comments/edit' => 'comments#edit'
  get 'comments/delete' => 'comments#delete'
  post 'comments/update' => 'comments#update'
  get 'comments/delete' => 'comments#delete'
  post 'messages/search' => 'messages#search'
  get 'auth/:provider/callback' => 'users#googlelogin'
  get 'chat' => 'chat#new'
  post 'chat/create' => 'chat#create'
  post 'charges' => 'charges#create'


  get 'users/show' => 'users#show'


  #get 'users/sign_up' => 'devise/registrations#new', :as => :users_signup
end
