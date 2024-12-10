class Libraries::BooksController < ApplicationController
  before_action :set_library
  before_action :set_book, only: %i[show edit update destroy read qr_code_download redirect_to_library]

  def index
    authorize @library, :show?
    @books = policy_scope(@library.books)
    @image_urls = fetch_cloudinary_images('Bookshelf')
  end

  def show
    set_library
    authorize @book
    @reviews = @book.reviews
  end

  def new
    @book = @library.books.new
    authorize @book
  end

  def create
    @book = @library.books.new(book_params)
    authorize @book

    if @book.save
      redirect_to library_book_path(@library, @book), notice: "Book successfully added."
    else
      render :new
    end
  end

  def edit
    authorize @book
  end

  def update
    authorize @book
    if @book.update(book_params)
      redirect_to library_book_path(@library, @book), notice: "Book successfully updated."
    else
      render :edit
    end
  end

  def destroy
    authorize @book
    @book.destroy
    redirect_to library_books_path(@library), notice: "Book successfully deleted."
  end

  def read
    authorize @book
    if @book.format == "ebook" && @book.pdf.attached?
      render 'read', locals: { pdf_url: url_for(@book.pdf) }
    else
      redirect_to library_book_path(@library, @book), alert: "This book is not available for online reading."
    end
  end

  def qr_code_download
    authorize @book

    send_data(
      RQRCode::QRCode.new(@book.qr_code).as_png(size: 300),
      type: 'image/png',
      filename: "qr_code_#{@book.title.parameterize}.png",
      disposition: 'attachment'
    )
  end

  def redirect_to_library
    # Authorize the library using Pundit
    if current_user.libraries.include?(@library)
      # User is already assigned to the library
      redirect_to library_path(@library), notice: "Welcome back to the library!"
    else
      # Assign user to library
      LibraryUser.create!(user: current_user, library: @library)
      redirect_to library_path(@library), notice: "You have been added to this library."
    end
  rescue Pundit::NotAuthorizedError
    # If authorization fails, redirect to a fallback page
    redirect_to root_path, alert: "You are not authorized to access this library."
  end


  private

  def set_library
    @library = Library.find(params[:library_id])
  end

  def set_book
    @book = @library.books.find(params[:id])
  end

  def book_params
    allowed_params = [:title, :summary, :author, :genre, :year, :format, :status]

    # Add conditional attributes
    allowed_params << :quantity << :qr_code if params[:book][:format] == "hardcover"
    allowed_params << :pdf if params[:book][:format] == "ebook"
    allowed_params << :photo # Photo is common for all formats

    params.require(:book).permit(allowed_params)
  end

  def fetch_cloudinary_images(folder)
    resources = Cloudinary::Api.resources(
      type: :upload,
      prefix: folder,
      max_results: 100 # Fetch up to 100 images from the folder
    )
    resources['resources'].map { |resource| resource['secure_url'] }
  rescue Cloudinary::Api::Error => e
    Rails.logger.error "Cloudinary API Error: #{e.message}"
    []
  end
end
