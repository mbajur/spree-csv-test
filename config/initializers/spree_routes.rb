Spree::Core::Engine.routes.prepend do
  namespace :admin do
    get "products/import", controller: :products, action: :import
    post "products/import", controller: :products, action: :import_create
  end
end
