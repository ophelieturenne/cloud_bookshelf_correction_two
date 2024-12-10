class LibrariesController < ApplicationController
  before_action :authenticate_user!

  def index
    @libraries = policy_scope(Library)
  end

  def show
    @library = Library.find(params[:id])
    Rails.logger.debug "Current user: #{current_user.inspect}"
    authorize @library

    # Paginate the books for the library
    @books = @library.books.page(params[:page]).per(8) # Adjust `per` as needed for items per page
  end


  def new
    @library = Library.new
    authorize @library
  end

  def create
    @library = Library.new(library_params)
    @library.unique_id = SecureRandom.uuid
    @library.user_id = current_user.id
    authorize @library

    if @library.save
      # Add the current user as an admin of the library
      LibraryUser.create!(library: @library, user: current_user, is_admin: true)

      # Redirect to the created library's show page
      redirect_to library_path(@library), notice: 'Library created successfully!'
    else
      Rails.logger.debug "Library Save Errors: #{@library.errors.full_messages}"
      flash.now[:alert] = @library.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end



  def edit
    @library = Library.find(params[:id])
    authorize @library
  end

  def update
    @library = Library.find(params[:id])
    authorize @library

    if @library.update(library_params)
      redirect_to @library, notice: "Library successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @library = Library.find(params[:id])
    authorize @library
    @library.destroy
    redirect_to libraries_path, notice: "Library deleted successfully."
  end

  def access_form
    skip_authorization # Since no specific library is being authorized
    @library_user = LibraryUser.new
  end


  def access
    unique_id = params[:library][:unique_id]
    @library = Library.find_by(unique_id: unique_id)

    if @library
      # Explicitly authorize access to the library
      authorize @library, :access?

      # Ensure the user is a member of the library
      unless @library.library_users.exists?(user: current_user)
        @library.library_users.create!(user: current_user)
      end

      redirect_to library_path(@library), notice: "Successfully accessed the library."
    else
      # If library is not found, still render with a helpful message
      skip_authorization
      redirect_to access_form_libraries_path, alert: "Library not found. Please check the Unique ID."
    end
  end




  private

  def library_params
    params.require(:library).permit(:name)
  end
end
