import React, { useState, useEffect } from 'react';
import axios from 'axios';
import DatePicker from 'react-datepicker';
import "react-datepicker/dist/react-datepicker.css";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';
const API = `${BACKEND_URL}/api`;

const SubscriptionManager = ({ onNavigate }) => {
  // States for search functionality
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  
  // States for subscription editor
  const [selectedMember, setSelectedMember] = useState(null);
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(false);
  
  // Form data for subscription update
  const [formData, setFormData] = useState({
    newExpiry: new Date(),
    planId: '',
    reason: ''
  });

  // Fetch plans on component mount
  useEffect(() => {
    fetchPlans();
  }, []);

  // Fetch plans from API
  const fetchPlans = async () => {
    try {
      const response = await axios.get(`${API}/plans`);
      setPlans(response.data);
    } catch (error) {
      console.error('Error fetching plans:', error);
    }
  };

  // Handle search input change with debounce
  const handleSearchChange = (e) => {
    const query = e.target.value;
    setSearchQuery(query);
    
    if (query.length >= 2) {
      setIsSearching(true);
      // Debounce search to avoid too many API calls
      const timeoutId = setTimeout(() => {
        searchMembers(query);
      }, 300);
      
      return () => clearTimeout(timeoutId);
    } else {
      setSearchResults([]);
      setIsSearching(false);
    }
  };

  // Search members API call
  const searchMembers = async (query) => {
    try {
      const response = await axios.get(`${API}/members?search=${query}`);
      setSearchResults(response.data);
      setIsSearching(false);
    } catch (error) {
      console.error('Error searching members:', error);
      setIsSearching(false);
    }
  };

  // Handle member selection from search results
  const handleSelectMember = (member) => {
    setSelectedMember(member);
    setSearchQuery(member.name); // Update search input with selected member name
    setSearchResults([]); // Clear search results
    
    // Initialize form with member's current plan and expiry date
    setFormData({
      newExpiry: new Date(member.end_date || Date.now()),
      planId: member.plan_id || '',
      reason: ''
    });
  };

  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  // Handle date change from DatePicker
  const handleDateChange = (date) => {
    setFormData(prev => ({
      ...prev,
      newExpiry: date
    }));
  };

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!selectedMember) {
      alert('Please select a member first');
      return;
    }
    
    setLoading(true);
    
    try {
      await axios.post(`${API}/subscriptions/manual-update`, {
        memberId: selectedMember.id,
        newExpiry: formData.newExpiry.toISOString(),
        planId: formData.planId,
        reason: formData.reason || undefined // Only include if provided
      });
      
      alert('Subscription updated successfully!');
      
      // Reset form
      setSelectedMember(null);
      setSearchQuery('');
      setFormData({
        newExpiry: new Date(),
        planId: '',
        reason: ''
      });
    } catch (error) {
      alert(error.response?.data?.detail || 'Failed to update subscription');
    } finally {
      setLoading(false);
    }
  };

  // Format date for display
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  // Get membership status with color coding
  const getMembershipStatus = (member) => {
    if (!member || !member.end_date) return { color: 'bg-gray-100 text-gray-800', text: 'Unknown' };
    
    const endDate = new Date(member.end_date);
    const today = new Date();
    const daysUntilExpiry = Math.ceil((endDate - today) / (1000 * 60 * 60 * 24));
    
    if (member.membership_status === 'active') {
      if (daysUntilExpiry < 0) {
        return { color: 'bg-red-100 text-red-800', text: 'Expired' };
      } else if (daysUntilExpiry <= 7) {
        return { color: 'bg-yellow-100 text-yellow-800', text: `${daysUntilExpiry} days left` };
      } else {
        return { color: 'bg-green-100 text-green-800', text: 'Active' };
      }
    } else {
      return { color: 'bg-gray-100 text-gray-800', text: member.membership_status };
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Subscription Manager</h1>
        <p className="text-gray-600">Search for members and update their subscriptions</p>
      </div>
      
      {/* Member Search Section */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <h2 className="text-lg font-semibold mb-4">Member Search</h2>
        
        <div className="relative">
          <input
            type="text"
            value={searchQuery}
            onChange={handleSearchChange}
            placeholder="Search members by name or email..."
            className="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          
          {isSearching && (
            <div className="absolute right-3 top-2">
              <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
            </div>
          )}
          
          {searchResults.length > 0 && (
            <div className="absolute z-10 mt-1 w-full bg-white rounded-md shadow-lg max-h-60 overflow-auto">
              {searchResults.map(member => (
                <div 
                  key={member.id} 
                  className="px-4 py-2 hover:bg-gray-100 cursor-pointer border-b border-gray-100 flex items-center justify-between"
                  onClick={() => handleSelectMember(member)}
                >
                  <div>
                    <div className="font-medium">{member.name}</div>
                    <div className="text-sm text-gray-600">{member.email}</div>
                  </div>
                  <div>
                    <span className={`${getMembershipStatus(member).color} px-2 py-1 rounded-full text-xs font-medium`}>
                      {getMembershipStatus(member).text}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
      
      {/* Subscription Editor Section */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-lg font-semibold mb-4">Subscription Editor</h2>
        
        {selectedMember ? (
          <div>
            <div className="mb-6 p-4 bg-gray-50 rounded-lg">
              <h3 className="font-medium text-gray-900">Selected Member</h3>
              <div className="mt-2 grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <span className="text-sm text-gray-500">Name</span>
                  <p className="font-medium">{selectedMember.name}</p>
                </div>
                <div>
                  <span className="text-sm text-gray-500">Current Plan</span>
                  <p className="font-medium">
                    {plans.find(p => p.id === selectedMember.plan_id)?.name || 'No Plan'}
                  </p>
                </div>
                <div>
                  <span className="text-sm text-gray-500">Expiry Date</span>
                  <p className="font-medium">
                    {selectedMember.end_date ? formatDate(selectedMember.end_date) : 'N/A'}
                  </p>
                </div>
              </div>
            </div>
            
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    New Expiry Date
                  </label>
                  <DatePicker
                    selected={formData.newExpiry}
                    onChange={handleDateChange}
                    dateFormat="MMMM d, yyyy"
                    minDate={new Date()}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    showIcon
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Plan
                  </label>
                  <select
                    name="planId"
                    value={formData.planId}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  >
                    <option value="">Select a plan</option>
                    {plans.map(plan => (
                      <option key={plan.id} value={plan.id}>
                        {plan.name} - ${plan.price} / {plan.duration_days} days
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Reason for Update (Optional)
                </label>
                <textarea
                  name="reason"
                  value={formData.reason}
                  onChange={handleInputChange}
                  placeholder="Enter reason for subscription update..."
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 h-24 resize-none"
                ></textarea>
              </div>
              
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setSelectedMember(null);
                    setSearchQuery('');
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {loading ? (
                    <span className="flex items-center">
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Updating...
                    </span>
                  ) : (
                    'Update Subscription'
                  )}
                </button>
              </div>
            </form>
          </div>
        ) : (
          <div className="text-center py-8 text-gray-500">
            <p>Search and select a member to update their subscription</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default SubscriptionManager;