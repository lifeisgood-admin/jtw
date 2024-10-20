Rails.application.routes.draw do
  get 'public_show/general_top'
    #ログイン--------------------------------------------------------------------------------
    scope 'login' do
        get '', to: 'sessions#new', as: :login
        post '', to: 'sessions#create'
    end
    scope 'logout' do
        get '', to: 'sessions#destroy', as: :logout
        delete '', to: 'sessions#destroy'
    end

    #管理画面--------------------------------------------------------------------------------
    scope 'admin' do
        get '', to: 'admin_top#index', as: :admin_top
  
        #パートナー情報--------------------------------------------------------------------------------
        scope 'partner' do
            get '', to: 'partners#index', as: :partner_index
            scope 'edit' do
                get '', to: 'partners#edit', as: :partner_new
                post '', to: 'partners#edit'
                get ':partner_id', to: 'partners#edit', as: :partner_edit
                patch ':partner_id', to: 'partners#edit'
            end
            get 'publish', to: 'partners#publish', as: :partner_publish
            get 'destroy', to: 'partners#destroy', as: :partner_destroy

            scope ':partner_id' do
                #管理者--------------------------------------------------------------------------------
                scope 'user' do
                    get '', to: 'users#index', as: :user_index
                    scope 'edit' do
                        get '', to: 'users#edit', as: :user_new
                        post '', to: 'users#edit'
                        get ':user_id', to: 'users#edit', as: :user_edit
                        patch ':user_id', to: 'users#edit'
                    end
                    get 'destroy', to: 'users#destroy', as: :user_destroy
                end

                #topic_category--------------------------------------------------------------------------------
                scope 'topic_category' do
                    get '', to: 'topics#index_category', as: :topic_category_index
                    scope 'edit' do
                        get '', to: 'topics#edit_category', as: :topic_category_new
                        post '', to: 'topics#edit_category'
                        get ':topic_category_id', to: 'topics#edit_category', as: :topic_category_edit
                        patch ':topic_category_id', to: 'topics#edit_category'
                    end
                    get 'destroy', to: 'topics#destroy_category', as: :topic_category_destroy
                    get 'publish', to: 'topics#publish_category', as: :topic_category_publish
        
                    scope ':topic_category_id' do
                        #topic--------------------------------------------------------------------------------
                        scope 'topic' do
                            get '', to: 'topics#index', as: :topic_index
                            scope 'edit' do
                                get '', to: 'topics#edit', as: :topic_new
                                post '', to: 'topics#edit'
                                get ':topic_id', to: 'topics#edit', as: :topic_edit
                                patch ':topic_id', to: 'topics#edit'
                            end
                            get 'destroy', to: 'topics#destroy', as: :topic_destroy
                            get 'publish', to: 'topics#publish', as: :topic_publish
                        end
                    end
                end
                
                #job--------------------------------------------------------------------------------
                scope 'job' do
                    get '', to: 'jobs#index', as: :job_index
                    scope 'edit' do
                        get '', to: 'jobs#edit', as: :job_new
                        post '', to: 'jobs#edit'
                        get ':job_id', to: 'jobs#edit', as: :job_edit
                        patch ':job_id', to: 'jobs#edit'
                    end
                    get 'destroy', to: 'jobs#destroy', as: :job_destroy
                    get 'publish', to: 'jobs#publish', as: :job_publish
                end

                #post--------------------------------------------------------------------------------
                scope 'post' do
                    get '', to: 'posts#index', as: :post_index
                    scope 'edit' do
                        get '', to: 'posts#edit', as: :post_new
                        post '', to: 'posts#edit'
                        get ':post_id', to: 'posts#edit', as: :post_edit
                        patch ':post_id', to: 'posts#edit'
                    end
                    get 'destroy', to: 'posts#destroy', as: :post_destroy
                    get 'publish', to: 'posts#publish', as: :post_publish
                end
            end
        end
    end
    
    #ユーザー画面--------------------------------------------------------------------------------
    get '', to: 'public_show#general_top', as: :general_top
    get 'about', to: 'public_show#about', as: :about
    get 'blog', to: 'public_show#blog', as: :blog

    #カテゴリー一覧--------------------------------------------------------------------------------    
    get 'job', to: 'public_show#search', as: :job_search
    get 'job_partner', to: 'public_show#search', as: :job_partner_search
    get 'service', to: 'public_show#search', as: :service_search
    get 'service_partner', to: 'public_show#search', as: :service_partner_search
    get 'business', to: 'public_show#business_partner', as: :business_search
    get 'business_partner', to: 'public_show#search', as: :business_partner_search
    get 'education_partner', to: 'public_show#search', as: :education_partner_search
    get 'worker_partner', to: 'public_show#search', as: :worker_partner_search
    get 'professional_partner', to: 'public_show#search', as: :professional_partner_search
    get 'ambassador_partner', to: 'public_show#search', as: :ambassador_partner_search

    scope ':partner_url' do
        get '', to: 'public_show#partner_top', as: :partner_top
        get 'info',to: 'public_show#partner_info', as: :aprtner_info
        get 'privacy_policy',to: 'public_show#partner_privacy_policy', as: :partner_privacy_policy
  
        #コンテンツ
        scope 'topic_category' do
            scope ':topic_category_id' do
                scope 'topic' do
                    get '',to: 'public_show#topic_list', as: :topic_list
                    get ':topic_id',to: 'public_show#topic', as: :topic
                end
            end
        end

        #求人
        scope 'job' do
            get '',to: 'public_show#job_list', as: :job_list
            get ':job_id',to: 'public_show#job', as: :job
        end

        #ポスト
        scope 'post' do
            get ':post_id',to: 'public_show#post', as: :post
        end
    end

  end
  