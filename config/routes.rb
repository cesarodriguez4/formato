Rails.application.routes.draw do
  get 'home/index'
  post 'home/index', to: 'home#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
