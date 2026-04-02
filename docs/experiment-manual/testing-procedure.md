# Testing Procedure

{% stepper %}
{% step %}
### Register participant

* [ ] NAME: EmmBig\_YYMMDD\_pID\_day
* [ ] Load protocol: Emma Biggs > ReactExt > Day 1 (or 2)
{% endstep %}

{% step %}
### Calibrate US intensity

_Stim PC > PsychoPy > Calibration script_

* [ ] Use right arrow to administer US
* [ ] Turn dial on DS7 to increase intensity (0.1 / 0.2 / 0.4 / 0.6 / 0.8)
* [ ] Increase until “unpleasant, requiring some effort to tolerate, not painful”
* [ ] Press ‘s’ to exit script
{% endstep %}

{% step %}
### Run Localizer

* [ ] Position functional slices approx. -20° from ACPC plane
* [ ] For next volumes:
  * [ ] ‘Copy parameters’
  * [ ] ‘Center of slice groups…’
  * [ ] ‘Adjustment volume…’
{% endstep %}

{% step %}
### Start Experiment

_On Stim PC_

* [ ] Enter participant codes (see participant log file)
* [ ] Start acqknowledge recording on Acq PC
* [ ] Press ‘s’ on Stim PC, wait for scanner trigger
* [ ] Start functional run (on MRI PC)
{% endstep %}

{% step %}
### End of testing session

* [ ] Stop Acqknowledge recording on Acq PC and save (pXX\_Phase)
* [ ] Turn DS7 safety switch on and turn off device
* [ ] Remove participant from scanner
* [ ] Export MRI data:
  * [ ] Patient browser > Transfer > Find EBiggs folder > Connect As > Create subject folder ‘…/01/’
* [ ] _If day 2_: Debrief participant (see corona specific measures)
* [ ] Export MRI data and close patient
* [ ] Reset scanner room (see corona specific measures)
* [ ] New paper on table, new earplugs
{% endstep %}

{% step %}
### End of testing day

* [ ] Back up data from Stim PC and Acq PC
* [ ] Remove equipment and put back in locker (code 1507)
* [ ] Return screen switch and response box switch
{% endstep %}
{% endstepper %}



## Scanning protocols

Localizer:

* 3 slice localizer

Multi-Band EPI sequences:

* MB\_EPI (& MB\_revEPI = reversed phase encoding)
* EPI, multi-band 2, 2mm-iso voxels, 2s TR, IPAT2, FOV 200mm, 46 slices
* Positioned approx. -20° from AC-PC orientation

T1 sequence:

* MPRAGE
* 192 slices, 1mm-iso voxels, FOV 256mm



<table><thead><tr><th>Day</th><th>Run</th><th>Sequence Type</th><th data-type="number">Volumes</th><th>Duration (MM:SS)</th></tr></thead><tbody><tr><td>Day 1</td><td>1</td><td>Localizer</td><td>null</td><td>00:13</td></tr><tr><td></td><td>2 <strong>ACQ</strong></td><td>MB_EPI</td><td>260</td><td>09:00</td></tr><tr><td></td><td>3</td><td>MB_revEPI</td><td>10</td><td>00:36</td></tr><tr><td></td><td></td><td></td><td>null</td><td></td></tr><tr><td>Day 2</td><td>4</td><td>Localizer</td><td>null</td><td>00:13</td></tr><tr><td></td><td>5 <strong>REACT</strong></td><td>MB_EPI</td><td>30</td><td>01:16</td></tr><tr><td></td><td>6 <em>Break</em></td><td>MB_revEPI</td><td>10</td><td>00:36</td></tr><tr><td></td><td>7 <em>Break</em></td><td>MPRAGE</td><td>null</td><td>08:26</td></tr><tr><td></td><td>8 <strong>EXT</strong></td><td>MB_EPI</td><td>524</td><td>17:30</td></tr><tr><td></td><td><em>Break</em></td><td></td><td>null</td><td>15:00</td></tr><tr><td></td><td>9 <strong>EXT-RE</strong></td><td>MB_EPI</td><td>375</td><td>12:45</td></tr><tr><td></td><td>10 <strong>REN</strong></td><td>MB_EPI</td><td>375</td><td>12:45</td></tr></tbody></table>



## COVID safety measures

> The 1.5m social distancing rules will be maintained where possible, however, contact between the experimenter and participant will be unavoidable at some points (i.e., preparation in the scanner). Therefore, the following rules will be observed:
>
> <br>
>
> * Upon arrival the participant and experimenter wash their hands with alcogel
> * When in contact with the participant (specifically: attaching electrodes and positioning participant in scanner) the experimenter will wear disposable gloves (replaced for each participant) and a (metal free) mouth mask.
> * For each participant a new paper cover will be used for the MRI table, as well as disposable cushion covers for the head padding.
> * The button boxes will be disinfected after every participant
> * The head coil will be disinfected after every participant.
> * At the end of the testing session the participant will be asked again to wash their hands with alcogel.
> * The waiting room at Scannexus will be arranged to maintain 1.5m social distancing.
> * Participants will be asked to arrive exactly 10 minutes before their appointment
> * Due to the expense of the scanning session it is not feasible to increase the time between consecutive appointments, but the next participant will only enter the scanning facilities once the previous participant has left.
>
> <br>
