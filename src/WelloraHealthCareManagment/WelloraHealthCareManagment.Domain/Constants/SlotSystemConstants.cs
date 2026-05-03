using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Constants
{
    public static class SlotSystemConstants
    {
        // Generation
        public const int MaxGenerationMonths = 3;
        public const int RollingWindowMonths = 2;
        public const int DefaultBatchSize = 1000;

        // Slot Duration
        public const int MinSlotDurationMinutes = 5;
        public const int MaxSlotDurationMinutes = 480;

        // Buffer
        public const int MinBufferMinutes = 0;
        public const int MaxBufferMinutes = 60;

        // Exception regeneration
        public const int MaxPastDaysForRegeneration = 1;
    }
}
