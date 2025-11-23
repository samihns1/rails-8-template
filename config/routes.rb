Rails.application.routes.draw do
  # Home
  root to: "home#index"
  get("/new_user", { :controller => "home", :action => "new_user" })

  # Routes for the Invitation resource:

  # CREATE
  post("/insert_invitation", { :controller => "invitations", :action => "create" })

  # READ
  get("/invitations", { :controller => "invitations", :action => "index" })

  get("/invitations/:path_id", { :controller => "invitations", :action => "show" })

  # UPDATE

  post("/modify_invitation/:path_id", { :controller => "invitations", :action => "update" })

  # DELETE
  get("/delete_invitation/:path_id", { :controller => "invitations", :action => "destroy" })

  #------------------------------

  # Routes for the Move resource:

  # CREATE
  post("/insert_move", { :controller => "moves", :action => "create" })

  # READ
  get("/moves", { :controller => "moves", :action => "index" })

  get("/moves/:path_id", { :controller => "moves", :action => "show" })

  # UPDATE

  post("/modify_move/:path_id", { :controller => "moves", :action => "update" })

  # DELETE
  get("/delete_move/:path_id", { :controller => "moves", :action => "destroy" })

  #------------------------------

  # Routes for the Gameplayer resource:

  # CREATE
  post("/insert_gameplayer", { :controller => "gameplayers", :action => "create" })

  # READ
  get("/gameplayers", { :controller => "gameplayers", :action => "index" })

  get("/gameplayers/:path_id", { :controller => "gameplayers", :action => "show" })

  # UPDATE

  post("/modify_gameplayer/:path_id", { :controller => "gameplayers", :action => "update" })

  # DELETE
  get("/delete_gameplayer/:path_id", { :controller => "gameplayers", :action => "destroy" })

  #------------------------------

  # Routes for the Game resource:

  # CREATE
  post("/insert_game", { :controller => "games", :action => "create" })

  # READ
  get("/games", { :controller => "games", :action => "index" })

  get("/games/:path_id", { :controller => "games", :action => "show" })

  # UPDATE

  post("/modify_game/:path_id", { :controller => "games", :action => "update" })

  # DELETE
  get("/delete_game/:path_id", { :controller => "games", :action => "destroy" })

  #------------------------------

  get("/join",       { :controller => "games", :action => "join_form" })
  post("/join_game", { :controller => "games", :action => "join_by_code" })

  devise_for :users
end
