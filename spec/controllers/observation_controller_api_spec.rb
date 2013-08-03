require File.dirname(__FILE__) + '/../spec_helper'

shared_examples_for "an ObservationsController" do

  describe "create" do
    it "should create" do
      lambda {
        post :create, :format => :json, :observation => {:species_guess => "foo"}
      }.should change(Observation, :count).by(1)
      o = Observation.last
      o.user_id.should eq(user.id)
      o.species_guess.should eq ("foo")
    end

    it "should include private coordinates in create response" do
      post :create, :format => :json, :observation => {:latitude => 1.2345, :longitude => 1.2345, :geoprivacy => Observation::PRIVATE}
      o = Observation.last
      o.should be_coordinates_obscured
      response.body.should =~ /#{o.private_latitude}/
      response.body.should =~ /#{o.private_longitude}/
    end

    it "should not fail if species_guess is a question mark" do
      post :create, :format => :json, :observation => {:species_guess => "?"}
      response.should be_success
      o = Observation.last
      o.species_guess.should eq('?')
    end

    it "should accept nested observation_field_values" do
      of = ObservationField.make!
      post :create, :format => :json, :observation => {
        :species_guess => "zomg", 
        :observation_field_values_attributes => {
          "0" => {
            :observation_field_id => of.id,
            :value => "foo"
          }
        }
      }
      response.should be_success
      o = Observation.last
      o.observation_field_values.last.observation_field.should eq(of)
      o.observation_field_values.last.value.should eq("foo")
    end
  end

  describe "destroy" do
    it "should destroy" do
      o = Observation.make!(:user => user)
      delete :destroy, :format => :json, :id => o.id
      Observation.find_by_id(o.id).should be_blank
    end

    it "should not destory other people's observations" do
      o = Observation.make!
      delete :destroy, :format => :json, :id => o.id
      Observation.find_by_id(o.id).should_not be_blank
    end
  end

  describe "show" do
    it "should provide private coordinates for user's observation" do
      o = Observation.make!(:user => user, :latitude => 1.23456, :longitude => 7.890123, :geoprivacy => Observation::PRIVATE)
      get :show, :format => :json, :id => o.id
      response.body.should =~ /#{o.private_latitude}/
      response.body.should =~ /#{o.private_longitude}/
    end

    it "should not provide private coordinates for another user's observation" do
      o = Observation.make!(:latitude => 1.23456, :longitude => 7.890123, :geoprivacy => Observation::PRIVATE)
      get :show, :format => :json, :id => o.id
      response.body.should_not =~ /#{o.private_latitude}/
      response.body.should_not =~ /#{o.private_longitude}/
    end

    it "should not include photo metadata" do
      p = LocalPhoto.make!(:metadata => {:foo => "bar"})
      p.metadata.should_not be_blank
      o = Observation.make!(:user => p.user, :taxon => Taxon.make!)
      op = ObservationPhoto.make!(:photo => p, :observation => o)
      get :show, :format => :json, :id => o.id
      response_obs = JSON.parse(response.body)
      response_photo = response_obs['observation_photos'][0]['photo']
      response_photo.should_not be_blank
      response_photo['metadata'].should be_blank
    end

    it "should include observation field values" do
      ofv = ObservationFieldValue.make!
      get :show, :format => :json, :id => ofv.observation_id
      response_obs = JSON.parse(response.body)
      response_obs['observation_field_values'].first['value'].should eq(ofv.value)
    end

    it "should include observation field values with observation field names" do
      ofv = ObservationFieldValue.make!
      get :show, :format => :json, :id => ofv.observation_id
      response_obs = JSON.parse(response.body)
      response_obs['observation_field_values'].first['observation_field']['name'].should eq(ofv.observation_field.name)
    end
  end

  describe "update" do
    before do
      @o = Observation.make!(:user => user)
    end

    it "should update" do
      put :update, :format => :json, :id => @o.id, :observation => {:species_guess => "i am so updated"}
      @o.reload
      @o.species_guess.should eq("i am so updated")
    end

    it "should accept nested observation_field_values" do
      of = ObservationField.make!
      put :update, :format => :json, :id => @o.id, :observation => {
        :observation_field_values_attributes => {
          "0" => {
            :observation_field_id => of.id,
            :value => "foo"
          }
        }
      }
      response.should be_success
      @o.reload
      @o.observation_field_values.last.observation_field.should eq(of)
      @o.observation_field_values.last.value.should eq("foo")
    end

    it "should updating existing observation_field_values" do
      ofv = ObservationFieldValue.make!(:value => "foo", :observation => @o)
      put :update, :format => :json, :id => ofv.observation_id, :observation => {
        :observation_field_values_attributes => {
          "0" => {
            :id => ofv.id,
            :observation_field_id => ofv.observation_field_id,
            :value => "bar"
          }
        }
      }
      response.should be_success
      ofv.reload
      ofv.value.should eq "bar"
    end

    it "should updating existing observation_field_values even if they're project fields" do
      pof = ProjectObservationField.make!
      po = make_project_observation(:project => pof.project, :user => user)
      ofv = ObservationFieldValue.make!(:value => "foo", :observation => po.observation, :observation_field => pof.observation_field)
      put :update, :format => :json, :id => ofv.observation_id, :observation => {
        :observation_field_values_attributes => {
          "0" => {
            :id => ofv.id,
            :observation_field_id => ofv.observation_field_id,
            :value => "bar"
          }
        }
      }
      response.should be_success
      ofv.reload
      ofv.value.should eq "bar"
    end

    it "should allow removal of nested observation_field_values" do
      ofv = ObservationFieldValue.make!(:value => "foo", :observation => @o)
      @o.observation_field_values.should_not be_blank
      put :update, :format => :json, :id => ofv.observation_id, :observation => {
        :observation_field_values_attributes => {
          "0" => {
            :_destroy => true,
            :id => ofv.id,
            :observation_field_id => ofv.observation_field_id,
            :value => ofv.value
          }
        }
      }
      response.should be_success
      @o.reload
      @o.observation_field_values.should be_blank
    end
  end

  describe "by_login" do
    it "should get user's observations" do
      3.times { Observation.make!(:user => user) }
      get :by_login, :format => :json, :login => user.login
      json = JSON.parse(response.body)
      json.size.should eq(3)
    end
  end

  describe "index" do
    it "should allow search" do
      lambda {
        get :index, :format => :json, :q => "foo"
      }.should_not raise_error
    end

    it "should filter by hour range" do
      o = Observation.make!(:observed_on_string => "2012-01-01 13:13")
      o.time_observed_at.should_not be_blank
      get :index, :format => :json, :h1 => 13, :h2 => 14
      json = JSON.parse(response.body)
      json.detect{|obs| obs['id'] == o.id}.should_not be_blank
    end

    it "should filter by date range" do
      o = Observation.make!(:observed_on_string => "2012-01-01 13:13")
      o.time_observed_at.should_not be_blank
      get :index, :format => :json, :d1 => "2011-12-31", :d2 => "2012-01-04"
      json = JSON.parse(response.body)
      json.detect{|obs| obs['id'] == o.id}.should_not be_blank
    end

    it "should filter by month range" do
      o1 = Observation.make!(:observed_on_string => "2012-01-01 13:13")
      o2 = Observation.make!(:observed_on_string => "2010-03-01 13:13")
      get :index, :format => :json, :m1 => 11, :m2 => 3
      json = JSON.parse(response.body)
      json.detect{|obs| obs['id'] == o1.id}.should_not be_blank
      json.detect{|obs| obs['id'] == o2.id}.should_not be_blank
    end

    it "should include pagination data in headers" do
      3.times { Observation.make! }
      total_entries = Observation.count
      get :index, :format => :json, :page => 2, :per_page => 30
      response.headers["X-Total-Entries"].to_i.should eq(total_entries)
      response.headers["X-Page"].to_i.should eq(2)
      response.headers["X-Per-Page"].to_i.should eq(30)
    end

    it "should not include photo metadata" do
      p = LocalPhoto.make!(:metadata => {:foo => "bar"})
      p.metadata.should_not be_blank
      o = Observation.make!(:user => p.user, :taxon => Taxon.make!)
      op = ObservationPhoto.make!(:photo => p, :observation => o)
      get :index, :format => :json, :taxon_id => o.taxon_id
      json = JSON.parse(response.body)
      response_obs = json.detect{|obs| obs['id'] == o.id}
      response_obs.should_not be_blank
      response_photo = response_obs['photos'].first
      response_photo.should_not be_blank
      response_photo['metadata'].should be_blank
    end

    it "should filter by conservation_status" do
      cs = without_delay {ConservationStatus.make!}
      t = cs.taxon
      o1 = Observation.make!(:taxon => t)
      o2 = Observation.make!(:taxon => Taxon.make!)
      get :index, :format => :json, :cs => cs.status
      json = JSON.parse(response.body)
      json.detect{|obs| obs['id'] == o1.id}.should_not be_blank
      json.detect{|obs| obs['id'] == o2.id}.should be_blank
    end

    it "should filter by conservation_status authority" do
      cs1 = without_delay {ConservationStatus.make!(:authority => "foo")}
      cs2 = without_delay {ConservationStatus.make!(:authority => "bar", :status => cs1.status)}
      o1 = Observation.make!(:taxon => cs1.taxon)
      o2 = Observation.make!(:taxon => cs2.taxon)
      get :index, :format => :json, :csa => cs1.authority
      json = JSON.parse(response.body)
      json.detect{|obs| obs['id'] == o1.id}.should_not be_blank
      json.detect{|obs| obs['id'] == o2.id}.should be_blank
    end

    it "should filter by establishment means" do
      p = make_place_with_geom
      lt1 = without_delay {ListedTaxon.make!(:establishment_means => ListedTaxon::INTRODUCED, :list => p.check_list, :place => p)}
      lt2 = without_delay {ListedTaxon.make!(:establishment_means => ListedTaxon::NATIVE, :list => p.check_list, :place => p)}
      o1 = Observation.make!(:taxon => lt1.taxon, :latitude => p.latitude, :longitude => p.longitude)
      o2 = Observation.make!(:taxon => lt2.taxon, :latitude => p.latitude, :longitude => p.longitude)
      get :index, :format => :json, :establishment_means => lt1.establishment_means, :place_id => p.id
      json = JSON.parse(response.body)
      json.detect{|obs| obs['id'] == o1.id}.should_not be_blank
      json.detect{|obs| obs['id'] == o2.id}.should be_blank
    end
  end

  describe "taxon_stats" do
    before do
      @o = Observation.make!(:observed_on_string => "2013-07-20", :taxon => Taxon.make!(:rank => Taxon::SPECIES))
      get :taxon_stats, :format => :json, :on => "2013-07-20"
      @json = JSON.parse(response.body)
    end

    it "should include a total" do
      @json["total"].to_i.should > 0
    end

    it "should include species_counts" do
      @json["species_counts"].size.should > 0
    end

    it "should include rank_counts" do
      @json["rank_counts"][@o.taxon.rank.downcase].should > 0
    end
  end

  describe "user_stats" do
    before do
      @o = Observation.make!(:observed_on_string => "2013-07-20", :taxon => Taxon.make!(:rank => Taxon::SPECIES))
      get :user_stats, :format => :json, :on => "2013-07-20"
      @json = JSON.parse(response.body)
    end

    it "should include a total" do
      @json["total"].to_i.should > 0
    end

    it "should include most_observations" do
      @json["most_observations"].size.should > 0
    end

    it "should include most_species" do
      @json["most_species"].size.should > 0
    end
  end
end

describe ObservationsController, "oauth authentication" do
  let(:user) { User.make! }
  let(:token) { stub :accessible? => true, :resource_owner_id => user.id, :application => OauthApplication.make! }
  before do
    request.env["HTTP_AUTHORIZATION"] = "Bearer xxx"
    controller.stub(:doorkeeper_token) { token }
  end
  it_behaves_like "an ObservationsController"
end

describe ObservationsController, "oauth authentication with param" do
  let(:user) { User.make! }
  it "should create" do
    app = OauthApplication.make!
    token = Doorkeeper::AccessToken.create(:application_id => app.id, :resource_owner_id => user.id)
    lambda {
      post :create, :format => :json, :access_token => token.token, :observation => {:species_guess => "foo"}
    }.should change(Observation, :count).by(1)
  end
end

describe ObservationsController, "devise authentication" do
  let(:user) { User.make! }
  before do
    http_login(user)
  end
  it_behaves_like "an ObservationsController"
end
