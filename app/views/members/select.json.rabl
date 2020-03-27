collection @users, :root => false, :object_root => false
attributes :id
node(:name){|a| highlight(a.name, params[:search]) }
node(:email){|a| highlight(a.email, params[:search]) }