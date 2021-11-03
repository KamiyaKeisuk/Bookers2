class BooksController < ApplicationController

  def index
    @user = current_user
    @book = Book.new
    to = Time.current.at_end_of_day
    from = (to- 6.day).at_beginning_of_day
    @books = Book.includes(:favorited_users).where(favorites: {created_at: from...to}).sort {|a,b| b.favorited_users.size <=> a.favorited_users.size}
    @books = Book.includes(:favorites).sort {|a,b| b.favorites.size <=> a.favorites.size}
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      flash[:success] = "You have created book successfully."
      redirect_to book_path(@book.id)
    else
      @books = Book.all
      @user = current_user
      render action: :index
    end
  end

  def show
    @book = Book.find(params[:id])
    @books = Book.all
    @user = @book.user
    @new_book = Book.new
    @book_comment = BookComment.new
  end

  def edit
    @book = Book.find(params[:id])
    if @book.user == current_user
      render "edit"
    else
      redirect_to books_path
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      flash[:success] = "You have updated book successfully."
      redirect_to book_path(@book.id)
    else
      render action: :edit
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end
end
