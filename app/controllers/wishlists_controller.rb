class WishlistsController < ApplicationController
  before_action :set_library
  before_action :authorize_wishlist, only: [:create, :destroy]

  def index
    @wishlists = policy_scope(@library.wishlists).where(user: current_user).page(params[:wish_page]).per(4) # Paginate
  end

  def create
    @wishlist = @library.wishlists.new(user: current_user, book_id: params[:book_id])

    if @wishlist.save
      redirect_to library_books_path(@library), notice: 'Book successfully added to wishlist.'
    else
      redirect_to library_books_path(@library), alert: @wishlist.errors.full_messages.to_sentence
    end
  end



  def destroy
    @wishlist = @library.wishlists.find(params[:id])
    @wishlist.destroy

    respond_to do |format|
      format.html { redirect_to library_wishlists_path(@library), notice: 'Wishlist item removed.' }
      format.turbo_stream
    end
  end

  private

  def set_library
    @library = Library.find(params[:library_id])
  end

  def authorize_wishlist
    @wishlist = Wishlist.new(library: @library, user: current_user)
    authorize @wishlist
  end

  def wishlist_params
    params.require(:wishlist).permit(:book_id)
  end
end
