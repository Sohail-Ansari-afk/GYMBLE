import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import { useDropzone } from 'react-dropzone';

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';

const PaymentSettings = () => {
  const [upiId, setUpiId] = useState('');
  const [qrCode, setQrCode] = useState(null);
  const [previewUrl, setPreviewUrl] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [upiError, setUpiError] = useState('');

  // Fetch current payment settings
  useEffect(() => {
    const fetchPaymentSettings = async () => {
      try {
        setLoading(true);
        const token = localStorage.getItem('token');
        const response = await axios.get(`${BACKEND_URL}/api/gym/payment-settings`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        
        if (response.data.upi_id) {
          setUpiId(response.data.upi_id);
        }
        
        if (response.data.qr_code) {
          setPreviewUrl(response.data.qr_code);
        }
        
        setLoading(false);
      } catch (err) {
        setError('Failed to load payment settings');
        setLoading(false);
        console.error('Error fetching payment settings:', err);
      }
    };

    fetchPaymentSettings();
  }, []);

  // Handle UPI ID validation and change
  const handleUpiChange = (e) => {
    const value = e.target.value;
    setUpiId(value);
    
    if (value && !value.includes('@')) {
      setUpiError('UPI ID must contain @ symbol');
    } else {
      setUpiError('');
    }
  };

  // Handle file drop for QR code
  const onDrop = useCallback(acceptedFiles => {
    if (acceptedFiles.length === 0) return;
    
    const file = acceptedFiles[0];
    if (!file.type.startsWith('image/')) {
      setError('Please upload an image file');
      return;
    }
    
    setQrCode(file);
    
    // Create preview URL
    const reader = new FileReader();
    reader.onload = () => {
      setPreviewUrl(reader.result);
    };
    reader.readAsDataURL(file);
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.svg']
    },
    maxFiles: 1
  });

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validate UPI ID if provided
    if (upiId && !upiId.includes('@')) {
      setUpiError('UPI ID must contain @ symbol');
      return;
    }
    
    try {
      setLoading(true);
      setError('');
      setSuccess('');
      
      const token = localStorage.getItem('token');
      const updateData = {};
      
      if (upiId) {
        updateData.upi_id = upiId;
      }
      
      if (qrCode) {
        // Convert QR code to base64
        const reader = new FileReader();
        reader.readAsDataURL(qrCode);
        
        await new Promise((resolve, reject) => {
          reader.onload = () => {
            updateData.qr_code = reader.result;
            resolve();
          };
          reader.onerror = reject;
        });
      }
      
      const response = await axios.patch(
        `${BACKEND_URL}/api/gym/payment-settings`,
        updateData,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      
      setSuccess('Payment settings updated successfully');
      setLoading(false);
    } catch (err) {
      setError('Failed to update payment settings');
      setLoading(false);
      console.error('Error updating payment settings:', err);
    }
  };

  // Handle QR code deletion
  const handleDeleteQrCode = () => {
    setQrCode(null);
    setPreviewUrl('');
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md">
      <h2 className="text-2xl font-semibold mb-6">Payment Settings</h2>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}
      
      {success && (
        <div className="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
          {success}
        </div>
      )}
      
      <form onSubmit={handleSubmit}>
        <div className="mb-6">
          <h3 className="text-lg font-medium mb-2">UPI ID</h3>
          <div className="mb-4">
            <label htmlFor="upiId" className="block text-sm font-medium text-gray-700 mb-1">
              Enter your UPI ID
            </label>
            <input
              type="text"
              id="upiId"
              value={upiId}
              onChange={handleUpiChange}
              placeholder="yourname@upi"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            {upiError && <p className="mt-1 text-sm text-red-600">{upiError}</p>}
          </div>
        </div>
        
        <div className="mb-6">
          <h3 className="text-lg font-medium mb-2">QR Code Management</h3>
          
          <div className="mb-4">
            <div 
              {...getRootProps()} 
              className={`border-2 border-dashed p-6 rounded-md text-center cursor-pointer ${isDragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300'}`}
            >
              <input {...getInputProps()} />
              {isDragActive ? (
                <p>Drop the QR code image here...</p>
              ) : (
                <p>Drag & drop a QR code image here, or click to select a file</p>
              )}
            </div>
          </div>
          
          {previewUrl && (
            <div className="mt-4">
              <h4 className="text-md font-medium mb-2">Current QR Code</h4>
              <div className="relative inline-block">
                <img 
                  src={previewUrl} 
                  alt="QR Code Preview" 
                  className="max-w-xs max-h-64 border rounded-md"
                />
                <button
                  type="button"
                  onClick={handleDeleteQrCode}
                  className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                  </svg>
                </button>
              </div>
            </div>
          )}
        </div>
        
        <div className="mt-6">
          <button
            type="submit"
            disabled={loading || (upiId && upiError)}
            className={`px-4 py-2 rounded-md text-white font-medium ${loading || (upiId && upiError) ? 'bg-gray-400 cursor-not-allowed' : 'bg-blue-600 hover:bg-blue-700'}`}
          >
            {loading ? 'Saving...' : 'Save Settings'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default PaymentSettings;