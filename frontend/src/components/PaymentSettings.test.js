import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import axios from 'axios';
import PaymentSettings from './PaymentSettings';

// Mock axios
jest.mock('axios');

// Mock react-dropzone
jest.mock('react-dropzone', () => ({
  __esModule: true,
  default: ({ onDrop, children }) => {
    const mockDropzone = (
      <div 
        data-testid="dropzone"
        onClick={() => {
          const file = new File(['dummy content'], 'qr-code.png', { type: 'image/png' });
          onDrop([file], []);
        }}
      >
        {children({ getRootProps: () => ({}), getInputProps: () => ({}) })}
      </div>
    );
    return mockDropzone;
  },
}));

// Mock FileReader
class MockFileReader {
  constructor() {
    this.result = 'data:image/png;base64,mockBase64Data';
  }
  readAsDataURL() {
    setTimeout(() => this.onload(), 0);
  }
}

global.FileReader = MockFileReader;

describe('PaymentSettings Component', () => {
  const mockNavigate = jest.fn();
  
  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();
    
    // Mock successful GET response
    axios.get.mockResolvedValue({
      data: {
        upi_id: 'test@upi',
        qr_code_data: 'data:image/png;base64,existingQrCodeData'
      }
    });
    
    // Mock successful PATCH response
    axios.patch.mockResolvedValue({
      data: {
        upi_id: 'updated@upi',
        qr_code_data: 'data:image/png;base64,updatedQrCodeData'
      }
    });
  });
  
  test('renders payment settings form', async () => {
    render(<PaymentSettings onNavigate={mockNavigate} />);
    
    // Wait for the component to load data
    await waitFor(() => {
      expect(axios.get).toHaveBeenCalledWith('/api/gym/payment-settings');
    });
    
    // Check if form elements are rendered
    expect(screen.getByText(/Payment Settings/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/UPI ID/i)).toBeInTheDocument();
    expect(screen.getByTestId('dropzone')).toBeInTheDocument();
    expect(screen.getByText(/Save Settings/i)).toBeInTheDocument();
  });
  
  test('loads existing payment settings', async () => {
    render(<PaymentSettings onNavigate={mockNavigate} />);
    
    await waitFor(() => {
      expect(screen.getByLabelText(/UPI ID/i).value).toBe('test@upi');
      expect(screen.getByAltText(/QR Code Preview/i)).toBeInTheDocument();
      expect(screen.getByAltText(/QR Code Preview/i).src).toContain('existingQrCodeData');
    });
  });
  
  test('handles UPI ID input change', async () => {
    render(<PaymentSettings onNavigate={mockNavigate} />);
    
    await waitFor(() => {
      expect(screen.getByLabelText(/UPI ID/i).value).toBe('test@upi');
    });
    
    // Change UPI ID
    fireEvent.change(screen.getByLabelText(/UPI ID/i), {
      target: { value: 'updated@upi' }
    });
    
    expect(screen.getByLabelText(/UPI ID/i).value).toBe('updated@upi');
  });
  
  test('handles QR code upload', async () => {
    render(<PaymentSettings onNavigate={mockNavigate} />);
    
    await waitFor(() => {
      expect(screen.getByTestId('dropzone')).toBeInTheDocument();
    });
    
    // Click on dropzone to trigger file upload
    fireEvent.click(screen.getByTestId('dropzone'));
    
    await waitFor(() => {
      // After upload, preview should be visible
      const preview = screen.getAllByAltText(/QR Code Preview/i)[0];
      expect(preview).toBeInTheDocument();
      expect(preview.src).toContain('mockBase64Data');
    });
  });
  
  test('handles form submission', async () => {
    render(<PaymentSettings onNavigate={mockNavigate} />);
    
    await waitFor(() => {
      expect(screen.getByLabelText(/UPI ID/i).value).toBe('test@upi');
    });
    
    // Change UPI ID
    fireEvent.change(screen.getByLabelText(/UPI ID/i), {
      target: { value: 'updated@upi' }
    });
    
    // Submit form
    fireEvent.click(screen.getByText(/Save Settings/i));
    
    await waitFor(() => {
      expect(axios.patch).toHaveBeenCalledWith(
        '/api/gym/payment-settings',
        expect.objectContaining({
          upi_id: 'updated@upi'
        })
      );
      
      // Success message should be displayed
      expect(screen.getByText(/Settings saved successfully/i)).toBeInTheDocument();
    });
  });
  
  test('handles API errors', async () => {
    // Mock API error
    axios.get.mockRejectedValueOnce(new Error('API Error'));
    
    render(<PaymentSettings onNavigate={mockNavigate} />);
    
    await waitFor(() => {
      expect(screen.getByText(/Error loading payment settings/i)).toBeInTheDocument();
    });
  });
  
  test('handles QR code deletion', async () => {
    render(<PaymentSettings onNavigate={mockNavigate} />);
    
    await waitFor(() => {
      expect(screen.getByAltText(/QR Code Preview/i)).toBeInTheDocument();
    });
    
    // Click delete button
    fireEvent.click(screen.getByText(/Remove/i));
    
    // QR code preview should be removed
    await waitFor(() => {
      expect(screen.queryByAltText(/QR Code Preview/i)).not.toBeInTheDocument();
    });
  });
});