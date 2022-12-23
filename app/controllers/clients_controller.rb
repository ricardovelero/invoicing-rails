class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]

  # GET /clients or /clients.json
  def index
    @clients = current_user.clients.includes(:invoices)
    @clients = current_user.clients.includes(:invoices).search(params[:query]) if params[:query].present?
    @pagy, @clients = pagy @clients.reorder(sort_column => sort_direction), items: params.fetch(:count, 10)
  end

  def sort_column
    %w{ first_name email nif }.include?(params[:sort]) ? params[:sort] : "first_name"
  end

  def sort_direction
    %w{ asc desc }.include?(params[:direction]) ? params[:direction] : "asc"
  end

  # GET /clients/1 or /clients/1.json
  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params)
    @client.user = current_user

    respond_to do |format|
      if @client.save
        format.html do
          redirect_to clients_url,
                      notice: "Client was successfully created."
        end
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: @client.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html do
          redirect_to clients_url,
                      notice: "Client was successfully updated."
        end
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: @client.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy

    respond_to do |format|
      format.html do
        redirect_to clients_url, notice: "Client was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = Client.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def client_params
    params.require(:client).permit(
      :user_id,
      :first_name,
      :last_name,
      :nif,
      :street,
      :city,
      :region,
      :postal_code,
      :country,
      :email,
      :telephone,
      :active
    )
  end
end
