class ProductsController < ApplicationController

before_action :set_category, only: [:new, :edit, :create, :update, :destroy]
before_action :set_product, only: [:show, :edit, :update, :destroy, :purchase, :buy, :set_category]
before_action :set_edit_category, only: [:edit]

    def index
        @products = Product.all.order("id DESC").limit(10)
        @products = Product.includes(:product_imgs).order('created_at DESC')

    end

    def new
        @product = Product.new
        @product.product_imgs.build
        @product.brands.build
        @parent = Category.where(id: 1..13)
        unless user_signed_in?
            flash[:alert] = "ログインしていません"
            redirect_to user_session_path
        else
            render :new
        end

    end

    def create
        @product = Product.new(product_params)
        if @product.save!
            flash[:notice] = "出品が完了しました。"
            redirect_to root_path
        else
            flash[:alert] = "出品に失敗しました。"
            render :new
        end
    end

    def show
        @product_img = @product.product_imgs.first
        @brand = Brand.find(@product.id)
    end

    def edit
        unless user_signed_in? && @product.user_id == current_user.id
            redirect_to product_path(@product)
        else
            render :edit
        end
    end

    def update
        if @product.user_id == current_user.id && @product.update(product_params)
            flash[:notice] = "更新が完了しました。"
            redirect_to product_path(@product)
        else
            render :edit
        end
    end

    def destroy
        if @product.user_id == current_user.id && @product.destroy
            flash[:alert] = "商品は削除されました。"
            redirect_to root_path
        else
            redirect_to product_path(@product.id)
        end
    end

    def search
      @products = Product.search(params[:keyword])
    end

    #jsonで親の名前で検索し、紐づく子カテゴリーの配列を取得
    def get_category_children
        @category_children = Category.find(params[:parent_id]).children
    end

    #jsonで子カテゴリーに紐づく孫カテゴリーの配列を取得
    def get_category_grandchildren
        @category_grandchildren = Category.find(params[:child_id]).children
    end

    #親カテゴリー
    def set_category
        @category_parent_array = Category.where(ancestry: nil)
    end

    #編集画面用のカテゴリー
    def set_edit_category
    @category_children_array = @product.category.parent.siblings
    @category_grandchildren_array = @product.category.siblings
    end

    private

    def set_product
        @product = Product.find(params[:id])
    end

    def product_params
        params.require(:product)
            .permit(:name, :price, :description, :condition,
                :size, :shipping_cost, :shipping_days,
                :prefecture, :trading_status,
                :category_id,
                product_imgs_attributes: [:image, :image_cache,:_destroy, :id],
                brands_attributes: [:name, :id]
            )
            .merge(user_id: current_user.id)
    end

end


