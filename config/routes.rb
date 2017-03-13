Spree::Core::Engine.add_routes do
  post '/checkout_finland', :to => "checkout_finland#checkout", :as => :checkout_finland
  get '/checkout_finland/confirm', :to => "checkout_finland#confirm", :as => :confirm_checkout_finland
  get '/checkout_finland/cancel', :to => "checkout_finland#cancel", :as => :cancel_checkout_finland
  get '/checkout_finland/notify', :to => "checkout_finland#notify", :as => :notify_checkout_finland

  namespace :admin do
    # Using :only here so it doesn't redraw those routes
    resources :orders, :only => [] do
      resources :payments, :only => [] do
        member do
          get 'checkout_finland_refund'
          post 'checkout_finland_refund'
        end
      end
    end
  end
end