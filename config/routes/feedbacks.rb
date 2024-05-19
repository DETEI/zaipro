Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # feedbacks
  match api_path + '/feedbacks',                     to: 'feedbacks#index',   via: :get
  match api_path + '/feedbacks',                     to: 'feedbacks#create',  via: :post

end