# frozen_string_literal: true

Rails.application.routes.draw do
  get 'home/index'
  post 'home/index', to: 'home#create'
  post 'home/download', to: 'home#download'
  match 'home/files/download/:filename' => 'home#download',
        :via => [:get], :as => :getfile
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
