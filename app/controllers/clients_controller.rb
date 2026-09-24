# frozen_string_literal: true

# Handles client management for the authenticated user.
#
# All client records are scoped to the current user to prevent access
# to records belonging to other accounts.
class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = current_user.clients.includes(:invoices)
    apply_search_query if params[:query].present?
    apply_pagination
  end

  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @client = current_user.clients.build
  end

  def edit; end

  def create
    @client = current_user.clients.build(client_params)
    respond_to { |format| handle_response(format) }
  end

  def update
    respond_to { |format| handle_update_response(format) }
  end

  def destroy
    respond_to { |format| handle_destroy_response(format) }
  end

  private

  def sort_column
    %w[first_name email nif].include?(params[:sort]) ? params[:sort] : 'first_name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def apply_search_query
    @clients = @clients.search(params[:query])
  end

  def apply_pagination
    @pagy, @clients = pagy(@clients.reorder(sort_column => sort_direction), items: pagination_count)
  end

  def pagination_count
    params.fetch(:count, 10).to_i.clamp(10, 100)
  end

  def handle_response(format) # rubocop:disable Metrics/AbcSize
    if @client.save
      format.html { redirect_to clients_url, notice: I18n.t('client_created') }
      format.json { render :show, status: :created, location: @client }
      format.turbo_stream { flash.now[:success] = I18n.t('client_created') }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @client.errors, status: :unprocessable_entity }
    end
  end

  def handle_update_response(format) # rubocop:disable Metrics/AbcSize
    if @client.update(client_params)
      format.html { redirect_to clients_url, notice: I18n.t('client_updated') }
      format.json { render :show, status: :ok, location: @client }
      format.turbo_stream { flash.now[:success] = I18n.t('client_updated') }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @client.errors, status: :unprocessable_entity }
    end
  end

  def handle_destroy_response(format) # rubocop:disable Metrics/MethodLength
    if @client.destroy
      format.html { redirect_to clients_url, notice: I18n.t('client_destroyed') }
      format.json { head :no_content }
    else
      format.html do
        redirect_to clients_url,
                    alert: @client.errors.full_messages.to_sentence,
                    status: :see_other
      end
      format.json { render json: @client.errors, status: :unprocessable_entity }
    end
  end

  def client_params # rubocop:disable Metrics/MethodLength
    params.require(:client).permit(
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
