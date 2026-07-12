using AutoMapper;
using MiniMart.DTOs;
using MiniMart.Repositories.Interfaces;
using MiniMart.Services.Interfaces;

namespace MiniMart.Services.Implementations
{
    public class EInvoiceService : IEInvoiceService
    {
        private readonly IEInvoiceRepository _eInvoiceRepository;
        private readonly IMapper _mapper;

        public EInvoiceService(IEInvoiceRepository eInvoiceRepository, IMapper mapper)
        {
            _eInvoiceRepository = eInvoiceRepository;
            _mapper = mapper;
        }

        public async Task<List<EInvoiceDto>> GetAllInvoicesAsync()
        {
            var invoices = _eInvoiceRepository.GetAllEInvoicesQueryable().ToList();
            return invoices.Select(_mapper.Map<EInvoiceDto>).ToList();
        }

        public async Task<EInvoiceDetailResponseDto?> GetInvoiceByIdAsync(int id)
        {
            var invoice = await _eInvoiceRepository.GetEInvoiceByIdAsync(id);
            if (invoice == null) return null;

            return new EInvoiceDetailResponseDto
            {
                Invoice = _mapper.Map<EInvoiceDto>(invoice),
                Items = invoice.EInvoiceDetails.Select(_mapper.Map<EInvoiceDetailDto>).ToList()
            };
        }

        public async Task<EInvoiceDto> CreateInvoiceFromOrderAsync(int orderId)
        {
            var invoice = await _eInvoiceRepository.CreateInvoiceFromOrderAsync(orderId);
            return _mapper.Map<EInvoiceDto>(invoice);
        }
    }
}
