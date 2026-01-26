Audits1984::Engine.routes.draw do
  resources :sessions, only: %i[ index show ] do
    resources :audits, only: %i[ create update ]
  end

  resource :filtered_sessions, only: %i[ update ]
  resource :auditor_token, only: %i[ show create destroy ]

  root to: "sessions#index"
end
