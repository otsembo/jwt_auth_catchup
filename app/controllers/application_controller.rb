class ApplicationController < ActionController::API
    include ActionController::Cookies


    def home
        if check_authentication_session
            render json: {
                message: 'Welcome home'
            }
        else
            unauthenticated
        end    
    end

    def home_jwt
        auth_headers = request.headers['Authorization']
        if !auth_headers
            unauthenticated
        else
            token = auth_headers.split(' ')[1]
            render json: {
                data: decode(token)[0]
            }
        end
    end

    def login_jwt
        type = app_login(email: params[:email], pass: params[:password])
        if type == nil
            unauthenticated
        else
           token = encode(params[:email], params[:password])
           render json: {
            token: token,
            message: "Success"
           }
        end  
    end

    def login
        type = app_login(email: params[:email], pass: params[:password])
        if type == :regular
            store_session(params[:email], "regular")
            authenticated
        elsif type == :admin
            store_session(params[:email], "admin")
            authenticated
        else
            unauthenticated
        end
    end

    def logout
        delete_session
        logged_out
    end

    def admin
        if check_admin_access_session
            render json: {
                message: "Welcome Admin"
            }
        else
            unauthenticated
        end
    end



    private

    # email: mail@mail.com, pass: mail, => regular
    # email: admin@mail.com, pass: admin, => admin

    # encode data
    def encode(email, password)
        expiry = Time.now.to_i + 3000
        data = {
            "email": email,
            "pass": password,
            "expiry": expiry
        }
        JWT.encode(data, "kuna venye", 'HS256')
    end

    #decode data
    def decode(token)
        JWT.decode(token, "kuna venye", true, {'algorithm':'HS256'})
    end


    def app_login(email: nil, pass: nil)
        if email == "mail@mail.com" && pass == "mail"
            :regular
        elsif email == "admin@mail.com" && pass == "admin"
            :admin
        else
            nil
        end
    end

    # set cookies
    def store_cookie(email, type)
        cookies[:email] = email
        cookies[:type] = type
    end

    # set session
    def store_session(email, type)
        session[:email] = email
        session[:type] = type
    end

    # delete cookies
    def delete_cookies
        cookies.delete(:type)
        cookies.delete(:email)
    end

    # delete session
    def delete_session
        session.delete(:type)
        session.delete(:email)
    end

    # check authentication (cookies)
    def check_authentication_cookies
        unauthenticated unless cookies[:email]
    end

    # check authentication (session)
    def check_authentication_session
        !!session[:email]  
    end

    # check admin access
    def check_admin_access_session
        session[:type] == 'admin'
    end

    # unauthenticated
    def unauthenticated
        render json: {
            message: 'You are not allowed to view this page'
        }, status: 401
    end

    def authenticated
        render json: {
            message: "Logged in as #{session[:type]}"
        }, status: 200
    end

    def logged_out
        render json: {
            message: "Goodbye!"
        }, status: 200
    end


end
