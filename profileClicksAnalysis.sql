-- MAIN PROJECT
 select
	pvs."createdAt" as profileViewTimestamp,
	ch."candidateId",
	ch.id as profileId,
	pvs."userType" as viewedBy,
	ch."snapshot" ->> 'firstName' as firstName,
	ch."snapshot" ->> 'lastName' as lastName,
	case
		when ch."snapshot" ->> 'profilePicture' is not null then '1'
		else '0'
	end as profilePicture,
	case
		when ch."snapshot" ->> 'pitchedVideo' is not null then '1'
		else '0'
	end as pitchVideo,
	case
		when ch."snapshot" ->> 'searchStatus' = 'Actively Searching' then '4'
		when ch."snapshot" ->> 'searchStatus' = 'Passively Searching' then '3'
		when ch."snapshot" ->> 'searchStatus' = 'Open to Offers, but Not Looking' then '2'
		else '1'
	end as searchStatus,
	substring(ch."snapshot" ->> 'activeInMarket', 1, 10) as activeInMarketDate,
	ch."snapshot" -> 'demographics' -> 'genderIdentity' ->> 'name' as gender,
	ch."snapshot" -> 'demographics' -> 'races' -> 0 ->> 'name' as race,
	(
	select
		*
	from
		json_array_elements(ch."snapshot" -> 'educations') e
	where
		e ->> 'isHighlighted' = 'true') -> 'school' ->> 'name' as school,
	(
	select
		*
	from
		json_array_elements(ch."snapshot" -> 'educations') e
	where
		e ->> 'isHighlighted' = 'true') ->> 'educationYear' as graduationYear,
	(
	select
		*
	from
		json_array_elements(ch."snapshot" -> 'educations') e
	where
		e ->> 'isHighlighted' = 'true') ->> 'degree' as "degree",
	(
	select
		*
	from
		json_array_elements(ch."snapshot" -> 'workExperiences') w
	where
		w ->> 'isHighlighted' = 'true') -> 'company' ->> 'name' as company,
	(
	select
		*
	from
		json_array_elements(ch."snapshot" -> 'workExperiences') w
	where
		w ->> 'isHighlighted' = 'true') -> 'title' ->> 'name' as "position",
	(
	select
		*
	from
		json_array_elements(ch."snapshot" -> 'workExperiences') w
	where
		w ->> 'isHighlighted' = 'true') ->> 'durationInMonths' as monthsAtCompany
from
	"profileViewStats" pvs
left join "candidateHistory" ch on
	pvs."candidateHistoryProfileId" = ch.id
	and pvs."candidateId" = ch."candidateId"
where
	pvs."userType" = 'client'
	and ch."candidateId" is not null
	--and pvs."viewedAtStage" = 'Source'
order by
	random();
