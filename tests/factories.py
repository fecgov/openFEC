import sqlalchemy as sa

import factory
from factory.alchemy import SQLAlchemyModelFactory

from webservices.rest import db
from webservices.common import models


class BaseFactory(SQLAlchemyModelFactory):
    class Meta:
        sqlalchemy_session = db.session


class CandidateSearchFactory(BaseFactory):
    class Meta:
        model = models.CandidateSearch

    id = factory.Sequence(lambda n: n)


class CommitteeSearchFactory(BaseFactory):
    class Meta:
        model = models.CommitteeSearch

    id = factory.Sequence(lambda n: n)


class BaseCandidateFactory(BaseFactory):
    candidate_id = factory.Sequence(lambda n: "ID{0}".format(n))


class CandidateFactory(BaseCandidateFactory):
    class Meta:
        model = models.Candidate

    election_years = [2012, 2014]


class CandidateDetailFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateDetail


class CandidateCommitteeTotalsPresidentialFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateCommitteeTotalsPresidential

    cycle = 2016


class CandidateCommitteeTotalsHouseSenateFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateCommitteeTotalsHouseSenate

    cycle = 2016


class CandidateHistoryFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateHistory

    two_year_period = 2016
    candidate_inactive = False


class CandidateHistoryFutureFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateHistoryWithFuture

    two_year_period = 2016
    candidate_inactive = False


class CandidateElectionFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateElection


class CandidateTotalFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateTotal

    cycle = 2016


class CandidateFlagsFactory(BaseFactory):
    class Meta:
        model = models.CandidateFlags

    federal_funds_flag = False
    has_raised_funds = True


class BaseCommitteeFactory(BaseFactory):
    committee_id = factory.Sequence(lambda n: "ID{0}".format(n))


class CommitteeFactory(BaseCommitteeFactory):
    class Meta:
        model = models.Committee


class CommitteeDetailFactory(BaseCommitteeFactory):
    class Meta:
        model = models.CommitteeDetail


class CommitteeHistoryFactory(BaseCommitteeFactory):
    class Meta:
        model = models.CommitteeHistory

    cycle = 2016


class CommitteeHistoryProfileFactory(CommitteeHistoryFactory):
    class Meta:
        model = models.CommitteeHistoryProfile

    cycle = 2016


class CommitteeTotalsHouseSenateFactory(BaseCommitteeFactory):
    class Meta:
        model = models.CommitteeTotalsHouseSenate

    cycle = 2016


# Force linked factories to share sequence counters
for each in BaseCandidateFactory.__subclasses__():
    each._meta.counter_reference = BaseCandidateFactory

for each in BaseCommitteeFactory.__subclasses__():
    each._meta.counter_reference = BaseCommitteeFactory


class CandidateCommitteeLinkFactory(BaseFactory):
    class Meta:
        model = models.CandidateCommitteeLink

    linkage_id = factory.Sequence(lambda n: n)


class CandidateCommitteeAlternateLinkFactory(BaseFactory):
    class Meta:
        model = models.CandidateCommitteeAlternateLink

    sub_id = factory.Sequence(lambda n: n)


class BaseTotalsFactory(BaseFactory):
    committee_id = factory.LazyAttribute(lambda o: CommitteeFactory().committee_id)
    cycle = 2016


class TotalsHouseSenateFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsHouseSenate


class TotalsPacPartyFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsPacParty


class TotalsPacFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsPacParty


class TotalsPartyFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsPacParty


class TotalsIEOnlyFactory(BaseFactory):
    class Meta:
        model = models.CommitteeTotalsIEOnly


class BaseReportsFactory(BaseFactory):
    committee_id = factory.LazyAttribute(lambda o: CommitteeFactory().committee_id)


class ReportsHouseSenateFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsHouseSenate


class ReportsPresidentialFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsPresidential


class ReportsPacPartyFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsPacParty


class EfileReportsPresidentialFactory(BaseFactory):
    class Meta:
        model = models.BaseF3PFiling


class EfileReportsPacPartyFactory(BaseFactory):
    class Meta:
        model = models.BaseF3XFiling


class EfileReportsHouseSenateFactory(BaseFactory):
    class Meta:
        model = models.BaseF3Filing


class ReportsIEOnlyFactory(BaseFactory):
    class Meta:
        model = models.CommitteeReportsIEOnly


class ScheduleAFactory(BaseFactory):
    class Meta:
        model = models.ScheduleA

    sub_id = factory.Sequence(lambda n: n)
    report_year = 2016
    two_year_transaction_period = 2016

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.contributor_name_text = sa.func.to_tsvector(obj.contributor_name)
        obj.contributor_employer_text = sa.func.to_tsvector(obj.contributor_employer)
        obj.contributor_occupation_text = sa.func.to_tsvector(
            obj.contributor_occupation
        )


class ScheduleBFactory(BaseFactory):
    class Meta:
        model = models.ScheduleB

    sub_id = factory.Sequence(lambda n: n)
    report_year = 2016
    two_year_transaction_period = 2016

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.disbursement_description_text = sa.func.to_tsvector(
            obj.disbursement_description
        )


class ScheduleCFactory(BaseFactory):
    class Meta:
        model = models.ScheduleC

    sub_id = factory.Sequence(lambda n: n)

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.candidate_name_text = sa.func.to_tsvector(obj.candidate_name)
        obj.loan_source_name_text = sa.func.to_tsvector(obj.loan_source_name)


class ScheduleCViewBySubIdFactory(BaseFactory):
    class Meta:
        model = models.ScheduleC

    sub_id = factory.Sequence(lambda n: n)


class ScheduleEFactory(BaseFactory):
    class Meta:
        model = models.ScheduleE

    sub_id = factory.Sequence(lambda n: n)
    report_year = 2016

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.payee_name_text = sa.func.to_tsvector(obj.payee_name)


class ScheduleBEfileFactory(BaseFactory):
    class Meta:
        model = models.ScheduleBEfile

    file_number = factory.Sequence(lambda n: n)
    related_line_number = factory.Sequence(lambda n: n)
    # report_year = 2016


class ScheduleEEfileFactory(BaseFactory):
    class Meta:
        model = models.ScheduleEEfile

    file_number = 123
    related_line_number = factory.Sequence(lambda n: n)


class ScheduleAEfileFactory(BaseFactory):
    class Meta:
        model = models.ScheduleAEfile

    file_number = factory.Sequence(lambda n: n)
    related_line_number = factory.Sequence(lambda n: n)


class ScheduleH4Factory(BaseFactory):
    class Meta:
        model = models.ScheduleH4

    sub_id = factory.Sequence(lambda n: n)
    report_year = 2016
    cycle = 2016

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.payee_name_text = sa.func.to_tsvector(obj.payee_name)
        obj.disbursement_purpose_text = sa.func.to_tsvector(obj.disbursement_purpose)


class FilingsFactory(BaseFactory):
    sub_id = factory.Sequence(lambda n: n)

    class Meta:
        model = models.Filings


class EFilingsFactory(BaseFactory):
    file_number = factory.Sequence(lambda n: n)

    class Meta:
        model = models.EFilings


class BaseFilingFactory(BaseFactory):
    file_number = factory.Sequence(lambda n: n)


class BaseF3PFilingFactory(BaseFilingFactory):
    class Meta:
        model = models.BaseF3PFiling


class BaseAggregateFactory(BaseFactory):
    committee_id = factory.Sequence(lambda n: str(n))
    cycle = 2016


class ScheduleABySizeFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleABySize


class ScheduleAByStateFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleAByState


class ScheduleAByEmployerFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleAByEmployer


class ScheduleBByPurposeFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleBByPurpose


class ScheduleBByRecipientFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleBByRecipient


class ScheduleBByRecipientIDFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleBByRecipientID


class ScheduleEByCandidateFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleEByCandidate

    candidate_id = factory.Sequence(lambda n: str(n))
    support_oppose_indicator = "S"


class CommunicationCostByCandidateFactory(BaseAggregateFactory):
    class Meta:
        model = models.CommunicationCostByCandidate

    candidate_id = factory.Sequence(lambda n: str(n))
    support_oppose_indicator = "S"


class ElectioneeringByCandidateFactory(BaseAggregateFactory):
    class Meta:
        model = models.ElectioneeringByCandidate

    candidate_id = factory.Sequence(lambda n: str(n))


class ReportTypeFactory(BaseFactory):
    class Meta:
        model = models.ReportType


class ReportDateFactory(BaseFactory):
    class Meta:
        model = models.ReportDate


class CalendarDateFactory(BaseFactory):
    class Meta:
        model = models.CalendarDate

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.summary_text = sa.func.to_tsvector(obj.summary)
        obj.description_text = sa.func.to_tsvector(obj.description)


class ElectionDateFactory(BaseFactory):
    class Meta:
        model = models.ElectionDate


class ElectionsListFactory(BaseFactory):
    class Meta:
        model = models.ElectionsList

    cycle = 2012


class ZipsDistrictsFactory(BaseFactory):
    class Meta:
        model = models.ZipsDistricts

    active = "Y"


class CommunicationCostFactory(BaseFactory):
    class Meta:
        model = models.CommunicationCost

    sub_id = factory.Sequence(lambda n: n)


class ScheduleDViewFactory(BaseFactory):
    class Meta:
        model = models.ScheduleD

    sub_id = factory.Sequence(lambda n: n)

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.creditor_debtor_name_text = sa.func.to_tsvector(obj.creditor_debtor_name)


class ScheduleDViewBySubIdFactory(BaseFactory):
    class Meta:
        model = models.ScheduleD

    sub_id = factory.Sequence(lambda n: n)


class ElectioneeringFactory(BaseFactory):
    class Meta:
        model = models.Electioneering

    idx = factory.Sequence(lambda n: n)
    election_type_raw = "G"

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.purpose_description_text = sa.func.to_tsvector(obj.purpose_description)


class RadAnalystFactory(BaseFactory):
    class Meta:
        model = models.RadAnalyst

    idx = factory.Sequence(lambda n: n)


class EntityReceiptDisbursementTotalsFactory(BaseFactory):
    class Meta:
        model = models.EntityReceiptDisbursementTotals

    idx = factory.Sequence(lambda n: n)


class ScheduleAByStateRecipientTotalsFactory(BaseFactory):
    class Meta:
        model = models.ScheduleAByStateRecipientTotals

    idx = factory.Sequence(lambda n: n)


class AuditCaseFactory(BaseFactory):
    class Meta:
        model = models.AuditCase

    audit_case_id = "2219"
    primary_category_id = "3"
    sub_category_id = "227"


class AuditCategoryFactory(BaseFactory):
    class Meta:
        model = models.AuditCategory

    primary_category_id = "3"


class AuditPrimaryCategoryFactory(BaseFactory):
    class Meta:
        model = models.AuditPrimaryCategory

    primary_category_id = "3"


class AuditCandidateSearchFactory(BaseFactory):
    class Meta:
        model = models.AuditCandidateSearch

    idx = factory.Sequence(lambda n: n)


class AuditCommitteeSearchFactory(BaseFactory):
    class Meta:
        model = models.AuditCommitteeSearch

    idx = factory.Sequence(lambda n: n)


class StateElectionOfficesFactory(BaseFactory):
    class Meta:
        model = models.StateElectionOfficeInfo

    state = "VA"
    office_type = "STATE CAMPAIGN FINANCE"


class OperationsLogFactory(BaseFactory):
    class Meta:
        model = models.OperationsLog


class TransactionCoverageFactory(BaseFactory):
    class Meta:
        model = models.TransactionCoverage


class TotalsCombinedFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsCombined


class CommitteeTotalsPerCycleFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsPerCycle

    idx = factory.Sequence(lambda n: n)


class PresidentialByCandidateFactory(BaseFactory):
    class Meta:
        model = models.PresidentialByCandidate

    idx = factory.Sequence(lambda n: n)


class PresidentialByStateFactory(BaseFactory):
    class Meta:
        model = models.PresidentialByState

    idx = factory.Sequence(lambda n: n)


class PresidentialSummaryFactory(BaseFactory):
    class Meta:
        model = models.PresidentialSummary

    idx = factory.Sequence(lambda n: n)


class PresidentialCoverageFactory(BaseFactory):
    class Meta:
        model = models.PresidentialCoverage

    idx = factory.Sequence(lambda n: n)


class PresidentialBySizeFactory(BaseFactory):
    class Meta:
        model = models.PresidentialBySize

    idx = factory.Sequence(lambda n: n)


class PacSponsorCandidateFactory(BaseFactory):
    class Meta:
        model = models.PacSponsorCandidate

    idx = factory.Sequence(lambda n: n)


class PacSponsorCandidatePerCycleFactory(BaseFactory):
    class Meta:
        model = models.PacSponsorCandidatePerCycle

    idx = factory.Sequence(lambda n: n)


class JFCCommitteeFactory(BaseFactory):
    class Meta:
        model = models.JFCCommittee

    idx = factory.Sequence(lambda n: n)


class TotalsInauguralDonationsFactory(BaseFactory):
    class Meta:
        model = models.InauguralDonations
