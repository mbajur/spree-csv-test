Spree::Core::Engine.routes.prepend do
  namespace :admin do
    get "products/import", controller: :products, action: :import
  end
end
