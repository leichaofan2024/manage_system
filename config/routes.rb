Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :employees do
    collection do
      post :import
    end 
  end
end
