Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'

  resources :homes, only: [:show] do
    get :step1, on: :collection
    get :step2, on: :collection
    get :step3, on: :collection
    get :partner_step3, on: :collection
    post :step2_create, on: :collection
    get :create_customer, on: :collection
  end

  resources :resellers do
    get :upgrade, on: :member
    post :upgrade_plan_request, on: :member
    post :cancel_plan_request, on: :member
  end

  resources :customers do
    get :upgrade, on: :member
    post :upgrade_plan_request, on: :member
    post :cancel_plan_request, on: :member
    post :set_as_sample, on: :member

    resources :customer_branches do #, only: [:create, :destroy]
      resources :company_users, only: [:create, :destroy]
    end

    resources :members

    resources :employees, only: [:update, :create, :destroy] do
      get :toggle_employee_domain, on: :member
      put :change_order, on: :member
    end

    resources :evaluations do
      get :dashboard, on: :member
      get :publish, on: :member
      get :full_report, on: :member
      get :full_assessment_report, on: :member
      get :expenses, on: :member
      get :dependences, on: :member
      post :pdf_assets, on: :member
      post :change_mass, on: :member
      post :set_as_sample, on: :member
      post :set_as_normal, on: :member
      post :recreate_sample_service_set, on: :member


      resources :evaluation_results do
        post :clone, on: :member
        get :toggle_employee, on: :member
        resources :evaluation_result_files, only: [:show, :create, :destroy]
      end
      resources :resources, only: [:index]
      resources :evaluation_processes
      resources :evaluation_services
    end
  end

  get '/customer/evaluation/rshow' => 'evaluations#rshow'

  resources :companies do
    resources :company_users, only: [:create, :destroy]
    resources :resellers do
      resources :members
      resources :customers do
        resources :customer_branches, only: [:create, :destroy]
      end
    end
    resources :customers do
      resources :customer_branches, only: [:create, :destroy]
    end
    resources :members
    get :switch, on: :member
  end

  resources :themes do
    get :eval_services_options, on: :member
  end
  resources :industries do
    get :eval_services_options, on: :member
  end
  resources :businesses
  resources :work_processes

  resources :members do
    get :select, on: :collection
    get :parent_companies, on: :collection
    post :invite, on: :new
  end

  resources :services do
    post :sort_all, on: :collection
  end
  resources :service_dependances, only: [:create, :destroy]
  resources :pages, only: [:show] do
    get :dynamic, on: :member
  end

  resources :new_service_requests

  resources :static_pages

  resources :licenses

  resources :invoices do
    put :set_internal_no
    put :set_status
  end

  resources :export_data, only: [:index] do
    get :download, on: :collection
    get :download_zip, on: :collection
  end

  devise_for :users, :controllers => { :registrations => "auth/registrations", :invitations => "auth/invitations" }

  root to: "homes#show"

  namespace :widgets do
    namespace :v1 do
      resources :registrations, only: [:new, :create]
    end
  end
end
