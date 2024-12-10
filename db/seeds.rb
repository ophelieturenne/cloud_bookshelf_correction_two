require 'faker'
require 'open-uri'

# Clear old data
puts "Clearing old data..."
[Review, Wishlist, Notification, Checkout, Book, LibraryUser, Library, User].each(&:destroy_all)
puts "All data cleared!"

# Create users
puts "Creating users..."
admin = User.create!(email: 'admin@cloudbookshelf.com', password: 'password123', admin: true)
librarian = User.create!(email: 'librarian@cloudbookshelf.com', password: 'password123')
student_1 = User.create!(email: 'student1@cloudbookshelf.com', password: 'password123')
student_2 = User.create!(email: 'student2@cloudbookshelf.com', password: 'password123')

puts "Users created: #{User.count}"

# Create libraries
puts "Creating libraries..."
library_1 = Library.create!(name: 'Central Library', user: admin)
library_2 = Library.create!(name: 'Science Library', user: librarian)

puts "Libraries created: #{Library.count}"

# Assign users to libraries
puts "Assigning users to libraries..."
LibraryUser.create!(user: librarian, library: library_1, is_admin: true)
LibraryUser.create!(user: student_1, library: library_1)
LibraryUser.create!(user: student_2, library: library_1)
LibraryUser.create!(user: librarian, library: library_2, is_admin: true)

puts "Library users assigned: #{LibraryUser.count}"

# Add books to libraries
puts "Adding books..."
20.times do
  format = %w[ebook hardcover researchpaper].sample
  book = Book.new(
    title: Faker::Book.title,
    summary: Faker::Lorem.paragraph,
    author: Faker::Book.author,
    genre: Faker::Book.genre,
    year: rand(1900..Date.today.year),
    format: format,
    library: library_1,
    user: librarian,
    quantity: (format == 'hardcover' ? rand(1..5) : nil),
    qr_code: (format == 'hardcover' ? SecureRandom.uuid : nil)
  )

  begin
    # Attach a default photo to the book
    book.photo.attach(
      io: File.open(Rails.root.join('app/assets/images/default_book_cover.jpg')),
      filename: 'default_book_cover.jpg',
      content_type: 'image/jpeg'
    )
  rescue Errno::ENOENT
    puts "Default book cover file not found! Skipping photo attachment for book: #{book.title}"
  end

  # Attach a default PDF if the book is an ebook
  if format == 'ebook'
    begin
      book.pdf.attach(
        io: File.open(Rails.root.join('app/assets/pdfs/sample_ebook.pdf')),
        filename: 'sample_ebook.pdf',
        content_type: 'application/pdf'
      )
    rescue Errno::ENOENT
      puts "Sample eBook PDF file not found! Skipping PDF attachment for book: #{book.title}"
    end
  end

  book.save!
  puts "Book created: #{book.title}, Format: #{book.format}"

  # Add reviews
  [student_1, student_2].each do |student|
    Review.create!(user: student, book: book, rating: rand(1..5), comment: Faker::Lorem.sentence)
  end

  # Add to wishlist
  Wishlist.create!(user: student_1, book: book, library: library_1)
end

puts "Books added: #{Book.count}, Reviews added: #{Review.count}, Wishlists created: #{Wishlist.count}"

# Create checkouts for hardcopy books
puts "Creating checkouts..."
library_1.books.where(format: 'hardcover').each do |book|
  next unless book.quantity.positive?

  Checkout.create!(
    user: student_1,
    book: book,
    library: library_1,
    start_date: Date.today,
    due_date: Date.today + 7.days,
    status: 'pending'
  )
  puts "Checkout created for book: #{book.title} (Remaining quantity: #{[book.quantity - 1, 0].max})"
end

puts "Checkouts created: #{Checkout.count}"

# Create notifications
puts "Creating notifications..."
Notification.create!(user: student_1, library: library_1, content: 'New books are now available in Central Library!')
Notification.create!(user: librarian, library: library_1, content: 'Please review the latest reservations.')

puts "Notifications created: #{Notification.count}"

puts "Seed data loaded successfully!"
