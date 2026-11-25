
Rails.application.routes.draw do

  resource :session
  resources :passwords, param: :token

  root "contacts#index"

  resources :contacts, only: [
    :index, :new, :create, :destroy
  ]

  get "up" => "rails/health#show",
      as: :rails_health_check

end
