class InvitationsController < ApplicationController
  def index
    matching_invitations = Invitation.all

    @list_of_invitations = matching_invitations.order({ :created_at => :desc })

    render({ :template => "invitation_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_invitations = Invitation.where({ :id => the_id })

    @the_invitation = matching_invitations.at(0)

    render({ :template => "invitation_templates/show" })
  end

  def create
    the_invitation = Invitation.new
    the_invitation.sender_id = params.fetch("query_sender_id")
    the_invitation.reciptent_email = params.fetch("query_reciptent_email")
    the_invitation.game_id = params.fetch("query_game_id")
    the_invitation.token = params.fetch("query_token")
    the_invitation.status = params.fetch("query_status")

    if the_invitation.valid?
      the_invitation.save
      redirect_to("/invitations", { :notice => "Invitation created successfully." })
    else
      redirect_to("/invitations", { :alert => the_invitation.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_invitation = Invitation.where({ :id => the_id }).at(0)

    the_invitation.sender_id = params.fetch("query_sender_id")
    the_invitation.reciptent_email = params.fetch("query_reciptent_email")
    the_invitation.game_id = params.fetch("query_game_id")
    the_invitation.token = params.fetch("query_token")
    the_invitation.status = params.fetch("query_status")

    if the_invitation.valid?
      the_invitation.save
      redirect_to("/invitations/#{the_invitation.id}", { :notice => "Invitation updated successfully." } )
    else
      redirect_to("/invitations/#{the_invitation.id}", { :alert => the_invitation.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_invitation = Invitation.where({ :id => the_id }).at(0)

    the_invitation.destroy

    redirect_to("/invitations", { :notice => "Invitation deleted successfully." } )
  end
end
