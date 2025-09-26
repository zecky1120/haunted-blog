# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]
  before_action :private_blog, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    permitted_params = %i[title content secret]
    if current_user.premium?
      permitted_params << [:random_eyecatch]
    end
    params.expect(blog: permitted_params)
  end

  def correct_user
    unless @blog.user_id == current_user.id
      redirect_to blogs_url, status: :not_found
    end
  end

  def private_blog
    if @blog.secret? && @blog.user != current_user
      redirect_to blogs_url, status: :not_found
    end
  end
end
