require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

	configure do
		set :views, "app/views"
		enable :sessions
		set :session_secret, "password_security"
	end

	#renders an index.erb file with links to signup or login.
	get "/" do
		erb :index
	end

	#renders a form to create a new user. The form includes fields for username and password
	get "/signup" do
		erb :signup
	end

	#make a new instance of our user class with a username and password from params
	#redirect to '/login' if the user is saved, or '/failure' if the user can't be saved
	post "/signup" do
		user = User.new(:username => params[:username], :password => params[:password])
		if user.save
			redirect "/login"
		  else
			redirect "/failure"
		  end
	end

	#renders a form for logging in
	get "/login" do
		erb :login
	end

	#did we find user by that username?
	#ensure that we have a User AND that that User is authenticated. 
	#If the user authenticates, we'll set the session[:user_id] and redirect to the /success route. 
	#Otherwise, we'll redirect to the /failure route so our user can try again.
	post "/login" do
		user = User.find_by(:username => params[:username])
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect "/success"
		else
			redirect "failure"
		end
	end

	#renders a success.erb page, which should be displayed once a user successfully logs in.
	get "/success" do
		if logged_in?
			erb :success
		else
			redirect "/login"
		end
	end 

	#renders a failure.erb page. This will be accessed if there is an error logging in or signing up
	get "/failure" do
		erb :failure
	end

	#clears the session data and redirects to the homepage.
	get "/logout" do
		session.clear
		redirect "/"
	end

	#logged_in? returns true or false based on the presence of a session[:user_id]
	helpers do
		def logged_in?
			!!session[:user_id]
		end

	#current_user returns the instance of the logged in user, based on the session[:user_id]
		def current_user
			User.find(session[:user_id])
		end
	end

end
