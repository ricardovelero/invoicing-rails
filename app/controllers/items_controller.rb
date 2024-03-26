class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: %i[show edit update destroy]

  # GET /items or /items.json
  def index
    @items = current_user.items
    @items = current_user.items.search(params[:query]) if params[:query].present?
    @pagy, @items = pagy @items.reorder(sort_column => sort_direction), items: params.fetch(:count, 10)
  end

  def sort_column
    %w[item_name description price iva].include?(params[:sort]) ? params[:sort] : 'item_name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  # GET /items/1 or /items/1.json
  def show
    @target = params[:target]
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit; end

  # POST /items or /items.json
  def create
    @item = Item.new(item_params)
    @item.user = current_user

    respond_to do |format|
      if @item.save
        format.html { redirect_to items_path, notice: I18n.t('item_creado') }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    if @item.update(item_params)
      respond_to do |format|
        format.html { redirect_to items_path, notice: I18n.t('item_actualizado') }
        format.json { render :show, status: :ok, location: @item }
      end
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @item.errors, status: :unprocessable_entity }
    end
  end

  # DELETE /items/1 or /items/1.json
  def destroy
    if @item.destroy
      respond_to do |format|
        format.html { redirect_to items_path, notice: I18n.t('item_borrado') }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to items_path, notice: I18n.t('item_fallo_borrar'), status: :unprocessable_entity }
        format.json { render json: { error: @item.errors.full_messages.join('. ') }, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.require(:item).permit(
      :user_id,
      :item_name,
      :description,
      :price,
      :iva
    )
  end
end
