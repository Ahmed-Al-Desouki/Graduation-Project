using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.DTOs.Prescriptions;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class PrescriptionService : IPrescriptionService
    {
        private readonly IPrescriptionRepository _prescriptionRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly HealthCarePlusContext _context;
        private readonly ILogger<PrescriptionService> _logger;

        public PrescriptionService(
            IPrescriptionRepository prescriptionRepository,
            IAppointmentRepository appointmentRepository,
            IUnitOfWork unitOfWork,
            HealthCarePlusContext context,
            ILogger<PrescriptionService> logger)
        {
            _prescriptionRepository = prescriptionRepository;
            _appointmentRepository = appointmentRepository;
            _unitOfWork = unitOfWork;
            _context = context;
            _logger = logger;
        }

        public async Task<PrescriptionResponse> CreatePrescriptionAsync(
            int doctorId,
            CreatePrescriptionRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Creating prescription for appointment {AppointmentId} by doctor {DoctorId}",
                    request.AppointmentId, doctorId);

                // 1. Verify appointment
                var appointment = await _appointmentRepository.GetByIdAsync(
                    request.AppointmentId, cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", request.AppointmentId);

                if (appointment.DoctorId != doctorId)
                    throw new UnauthorizedAccessException(
                        "Not authorized to create prescription for this appointment");

                // 2. Generate prescription number
                var prescriptionNumber = await GeneratePrescriptionNumber(doctorId);

                // 3. Create prescription
                var prescription = Prescription.Create(
                    request.AppointmentId,
                    doctorId,
                    appointment.PatientId,
                    prescriptionNumber);

                if (request.ValidUntil.HasValue)
                    prescription.SetValidity(request.ValidUntil.Value);

                if (!string.IsNullOrWhiteSpace(request.SpecialInstructions))
                    prescription.SetSpecialInstructions(request.SpecialInstructions);

                // 4. Add prescription items
                foreach (var item in request.Items)
                {
                    prescription.AddItem(
                        item.MedicationName,
                        item.Dosage,
                        item.Frequency,
                        item.Duration,
                        item.Quantity,
                        item.Instructions);
                }

                await _prescriptionRepository.AddAsync(prescription, cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Prescription {PrescriptionId} created with {ItemCount} items",
                    prescription.Id, request.Items.Count);

                return MapToResponse(prescription);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "Error creating prescription for appointment {AppointmentId}",
                    request.AppointmentId);
                throw;
            }
        }

        public async Task<PrescriptionResponse?> GetPrescriptionAsync(
            Guid prescriptionId,
            CancellationToken cancellationToken = default)
        {
            var prescription = await _prescriptionRepository.GetByIdWithItemsAsync(
                prescriptionId, cancellationToken);

            if (prescription == null)
                return null;

            return MapToResponse(prescription);
        }

        public async Task<List<PrescriptionResponse>> GetAppointmentPrescriptionsAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            var prescriptions = await _prescriptionRepository.GetByAppointmentIdAsync(
                appointmentId, cancellationToken);

            return prescriptions.Select(MapToResponse).ToList();
        }

        public async Task<List<PrescriptionResponse>> GetPatientPrescriptionsAsync(
            int patientId,
            CancellationToken cancellationToken = default)
        {
            var prescriptions = await _prescriptionRepository.GetByPatientIdAsync(
                patientId, cancellationToken);

            return prescriptions.Select(MapToResponse).ToList();
        }

        //public async Task AddPrescriptionItemAsync(
        //    Guid prescriptionId,
        //    int doctorId,
        //    PrescriptionItemRequest request,
        //    CancellationToken cancellationToken = default)
        //{
        //    await _unitOfWork.BeginTransactionAsync(cancellationToken);

        //    // جيب الـ Prescription بدون Include (كويس عشان نقلل الـ tracking overhead)
        //    var prescription = await _prescriptionRepository.GetByIdAsync(prescriptionId, cancellationToken);

        //    if (prescription == null)
        //        throw new NotFoundException("Prescription", prescriptionId);

        //    if (prescription.DoctorId != doctorId)
        //        throw new UnauthorizedAccessException("غير مصرح لك بتعديل هذه الوصفة");

        //    // أضف العنصر عبر Domain method (يحافظ على Domain purity)
        //    prescription.AddItem(
        //        request.MedicationName,
        //        request.Dosage,
        //        request.Frequency,
        //        request.Duration,
        //        request.Quantity,
        //        request.Instructions);

        //    // ← الحل المهم: استخرج الـ item الجديد من الـ collection وعدل stateها لـ Added
        //    // (ده بيضمن INSERT بدون ما يأثر على الـ parent)
        //    var newItem = prescription.Items.Last();  // أو ItemsList.Last() إن كنت مستخدمها
        //    _context.Entry(newItem).State = EntityState.Added;

        //    // منع الـ parent من update وهمي (كما قبل)
        //    _context.Entry(prescription).State = EntityState.Unchanged;

        //    // اختياري: لو عايز تحدث UpdatedAt للـ Prescription
        //    // prescription.UpdatedAt = DateTime.UtcNow;
        //    // _context.Entry(prescription).Property(p => p.UpdatedAt).IsModified = true;

        //    await _unitOfWork.CommitTransactionAsync(cancellationToken);

        //    _logger.LogInformation("Item added successfully {PrescriptionId}", prescriptionId);
        //}

        public async Task AddPrescriptionItemAsync(
            Guid prescriptionId,
            int doctorId,
            PrescriptionItemRequest request,
            CancellationToken cancellationToken = default)
        {
            await _unitOfWork.BeginTransactionAsync(cancellationToken);

            var prescription = await _prescriptionRepository.GetByIdAsync(prescriptionId, cancellationToken);

            if (prescription == null)
                throw new NotFoundException("Prescription", prescriptionId);

            if (prescription.DoctorId != doctorId)
                throw new UnauthorizedAccessException("You are not authorized to modify this recipe.");

            prescription.AddItem(
                request.MedicationName,
                request.Dosage,
                request.Frequency,
                request.Duration,
                request.Quantity,
                request.Instructions);

            var newItem = prescription.Items.Last();

            await _prescriptionRepository.AddPrescriptionItemAsync(
                prescriptionId,
                newItem,
                cancellationToken);

            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            _logger.LogInformation("An item has been added successfully. {PrescriptionId}", prescriptionId);
        }

        private async Task<string> GeneratePrescriptionNumber(int doctorId)
        {
            // Format: RX-YYYYMMDD-DOCID-RANDOM
            var today = DateTime.UtcNow.ToString("yyyyMMdd");
            var random = new Random().Next(1000, 9999);
            return $"RX-{today}-{doctorId}-{random}";
        }

        private PrescriptionResponse MapToResponse(Prescription prescription)
        {
            return new PrescriptionResponse
            {
                PrescriptionId = prescription.Id,
                PrescriptionNumber = prescription.PrescriptionNumber,
                IssuedAt = prescription.IssuedAt,
                ValidUntil = prescription.ValidUntil,
                Items = prescription.Items.Select(i => new PrescriptionItemDto
                {
                    ItemId = i.Id,
                    MedicationName = i.MedicationName,
                    Dosage = i.Dosage,
                    Frequency = i.Frequency,
                    Duration = i.Duration,
                    Quantity = i.Quantity,
                    Instructions = i.Instructions
                }).ToList()
            };
        }
    }
}