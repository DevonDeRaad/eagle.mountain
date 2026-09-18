xGen™ ssDNA & Low-Input DNA Library Preparation Kit Protocol For Historical DNA

This protocol takes degraded historical DNA to finished whole genome libraries using a special kit for low input of single stranded DNA. DNA after extraction is fragmented to 70-120bp by the passage of time. First, fragments are singularized (if not already single stranded) and a single stubby adapter is ligated to the i7 end of the fragment. These adapters are stubby because they do not contain all the flowcell binding sequence, just the sequencing read primers. The stubby adapter can then act as a primer to extend a complimentary fragment. The full flowcell binding sequence, and unique dual indexing sequences are added on in the index addition by PCR step. Unique dual indexing sequences allow one to tell different samples apart when all the libraries are combined for sequencing.

[Set up and Planning 2](#_Toc240551027)

[Materials 2](#_Toc240551028)

[Starting DNA quantity and fragment size 2](#_Toc240551029)

[Preparing samples and sample organization 3](#_Toc240551030)

[Index planning 3](#_Toc240551031)

[Preparing samples and aliquoting before prep 3](#_Toc240551032)

[Library Preparation 4](#_Toc240551033)

[Adaptase reaction 4](#_Toc240551034)

[Extension 5](#_Toc240551035)

[Post-Extension Cleanup 5](#_Toc240551036)

[Ligation 7](#_Toc240551037)

[Post-Ligation Cleanup 7](#_Toc240551038)

[Index Amplification 8](#_Toc240551039)

[Post-Indexing Cleanup 1 9](#_Toc240551040)

[Post-Indexing Cleanup 2 10](#_Toc240551041)

#

# Set up and Planning

## Materials

- [96 reaction kit catalog number 10009817](https://www.idtdna.com/pages/products/next-generation-sequencing/workflow/xgen-ngs-library-preparation/dna-library-preparation/ssdna-low-input-dna-library-prep-kit) - stored in -20 freezer
- [xGen™ UDI Primers Plate 1, 8nt catalog number 10005922](https://www.idtdna.com/pages/products/next-generation-sequencing/workflow/xgen-ngs-library-preparation/dna-library-preparation/ssdna-low-input-dna-library-prep-kit) - stored in -20 freezer
  - Note if sequencing more than 96 samples at a time use "xGen™ UDI 10nt Primer Plates 1-4" this provides indexes for 384 samples that can be sequenced together. Catalog number 10008052
- SPRI beads
- DNase-RNase free 8 strip tubes
- DNase-RNase free 1.5mL tubes
- p10, p20, p200, and p1000 filter tips
- Freshly prepared 80% ethanol, room temp
- Nuclease free water, room temp
- Low EDTA TE (provided with kit), room temp, reorder from IDT catalog number [11-05-01-15](https://www.idtdna.com/pages/products/reagents-and-kits/buffers-and-solutions) (make sure it is 0.1mM EDTA)
- 96 well magnet plate
- PCR machine (2 if possible)
- Ice bucket and ice

## Starting DNA quantity and fragment size

The amount of DNA that this kit can handle is between 10pg to 250ng. Because this kit is for use with historical DNA samples, the input may be necessarily low, however you should always try to maximize the input to the best of your abilities. Having greater input requires fewer PCR cycles later on and that helps reduce PCR bias.

**Note that the input volume for the kit is 15ul of DNA and the samples must be in Low ETDA TE buffer**. Samples must be eluted from their final bead clean prior to library prep with Low EDTA TE buffer. If you have samples ready for prep but are in the wrong buffer, they must be buffer exchanged using beads. It is not advised to dry down the samples in the vacuum centrifuge because this does not remove any of the salts/chemicals from the original buffer. 

Historical DNA is highly fragmented and degraded. You will not need to sonicate to shear DNA for use with this kit. This kit expects DNA pieces to be on average either 200bp or 350bp. This is not possible with our historic DNA samples, where the average fragment size is between 70 and 120bp usually.

So, historical DNA samples probably **do not** need to be sonicated for library prep. But you should look at some of your extracted DNA to be sure. However, if you are using modern DNA with this kit you will need to sonicate it to either an average size of 350bp or 200bp. **This protocol is currently written with specifications for DNA ~100bp long historical DNA.** There are different specifications for DNA at 200 or 350bp. You will have to go to the IDT kit protocol to revise this protocol.

## Preparing samples and sample organization

### Index planning

Before you start, you will want to assign an index pair to each one of your samples. Indexes are sets of 8-10 nucleotides that are added to each sample (individual) that are used to bioinformatically separate out the samples post sequencing. Before sequencing, all sample libraries get combined into one tube, so you will need to tell them apart molecularly. **It is very important to only ever assign 1 set of indexes to only 1 sample**, otherwise you will not be able to use the sample after sequencing.

For sequencing on patterned flow cells (any of these machines: NovaSeq 6000, NovaSeq X/X Plus, NextSeq 1000/2000, iSeq 100, HiSeq 3000/4000/X) unique dual indexes (UDIs) are required. And it can be best practice to exclusively use UDIs when doing library prep. UDIs add two different sets of 8-10 nucleotides to each side of the piece of DNA, so that each sample gets two different unique sets of 8-10 nucleotides. Assign 1 well position/primer name to each sample uniquely.

### Preparing samples and aliquoting before prep

**Always dilute your samples with low EDTA TE buffer**. Make sure to vortex and spin down samples after thawing, and keep them on ice while diluting and thawing. Dilute each sample to the desired input amount in low EDTA TE buffer to 15ul in strip tubes. Freeze these aliquots in -20 to be used on the day of library prep if not handling that day.

#

# Library Preparation

## Adaptase reaction

1. Take SPRI beads out of the refrigerator to equilibrate to room temperature in the dark
2. Thaw 15ul sample aliquots on ice and spin down after thawing
3. Place a low EDTA TE buffer aliquot on ice to cool down
4. Thaw needed reagents on ice (note enzymes are stored in glycerol, making them viscous and liquid at -20C and should therefore be placed deep in ice and pipetted carefully):
   1. Buffer G1
   2. Reagent G2
   3. Reagent G3
   4. Enzyme G4
   5. Enzyme G5
   6. Enzyme G6
5. Vortex to mix and spin down all reagents a-f above and place back on ice
6. Prepare Adaptatse Master Mix in a 1.5mL tube on ice. Each component already includes 5% extra to account for error during pipetting. Add components in order to the tube. Note that "n" is the number of samples you are preparing:
   1. 12.075ul Low EDTA TE \* n =
   2. 4.2ul Buffer G1 \* n =
   3. 4.2ul Reagent G2 \* n =
   4. 2.625ul Reagent G3 \* n =
   5. 1.05ul Enzyme G4 \* n =
   6. 1.05ul Enzyme G5 \* n =
   7. 1.05ul Enzyme G6 \* n =
7. Vortex the Adaptase Master mix, spin down, and place back on ice
8. Place 15ul sample aliquots in the thermocycler, and program a denature program:
   1. 2 min at 95 C
   2. Note: lid set to 105C
9. Immediately after the 2 minutes place the sample tubes back on ice for at least 2 minutes (samples must be cooled before adding adaptase enzymes)
10. Immediately start the following thermocycler program to get the block to the correct temperature:
    1. Hold at 37C
    2. 15 min at 37C
    3. 2 min 95C
    4. Hold at 4C
    5. Note: lid set to 105C
11. Add 25ul of Adaptase Master mix to each sample tube and pipette mix 10X
12. Spin down tubes
13. Place sample tubes in thermocycler and continue the program by pressing "skip step" to move past the hold

## Extension

1. During the time the samples are in the thermocycler, begin preparing for the next step
2. Thaw needed reagents on ice:
   1. Reagent Y1
   2. Reagent W2 E
   3. Buffer W3 E
   4. Enzyme W4 E
3. Vortex to mix and spin down all reagents a-d above and place back on ice
4. Keep Low EDTA TE buffer on ice as well
5. Prepare the Extension Master Mix in a 1.5mL tube on ice. Each component already includes 5% extra to account for error during pipetting. Add components in order to the tube:
   1. 19.325ul Low EDTA TE \* n =
   2. 2.1ul Reagent Y1 \* n =
   3. 7.35ul Reagent W2 E \* n =
   4. 18.375ul Buffer W3 E \* n =
6. Keep Extension Master mix on ice without reagent W4 until the samples are out of thermocycler adaptase program
7. Once samples are done in the thermocycler, take them out and place them on ice
8. Start the thermocycler start the following thermocycler program so it can pre-heat:
   1. Hold at 98C
   2. 30 seconds 98C
   3. 15 seconds 63C
   4. 5 minutes 68C
   5. Hold at 4C
   6. Note: lid set to 105C
9. Add enzyme W4 E to the Extension Master Mix:
   1. 2.1 \* n =
10. Vortex and spin down the Extension Master Mix and keep on ice
11. Add 47ul of Extension Master Mix to each sample and pipette mix 10X and spin down tubes
12. Place sample tubes in thermocycler and press "skip step" to continue the extension program

## Post-Extension Cleanup

1. **Note this bead clean uses different ratios than the xGen low input DNA kit standard protocol to account for DNA fragments below 200bp**
2. Warm SPRI beads to room temperature in a drawer/away from light and swirl them gently to resuspend the beads
3. Prepare fresh 80% ethanol each day you do library prep (10mL molecular grade water and 40mL 100% ethanol) and store at room temperature
4. Take samples out of the thermocycler and place them at room temp on the workbench, the volume inside each tube should be 87ul
   1. Leave the lid of the thermocycler open to cool it in preparation for the ligation program
5. Add 156ul of SPRI beads to each sample (1.8X) and pipette mix at least 10X (this maxes out the tube volume so this will be hard to do, you must pipette slowly and carefully)
6. Place samples on an orbital mixer shaking at 300rpm for 10 minutes, or if no mixer is available leave at room temperature on the bench for 10 minutes
7. Place samples on the magnet rack and tape it to the mixer shaking at 300rpm for at least 10 minutes to let the beads bind to the magnet. If there is no mixer available, you may need to wait 15 minutes. Because the volume in the tubes is so large it will take a long time for the beads get to the magnet.
8. Slowly pipette up ~150ul of the clear-ish supernatant and add it back into the tube to help make sure all the beads in solution get to the magnet (the magnet is very low down in the magnet plate). Make sure you don't pipette the bead pellet during this
9. Remove supernatant without disturbing the beads (220ul; use a P200 and then P20)
10. Add 200ul fresh 80% ethanol to each tube without disturbing the beads
11. Remove supernatant from each tube without disturbing the beads
12. Add 190ul fresh 80% ethanol to each tube without disturbing the beads
13. Remove supernatant from each tube without disturbing the beads (200ul)
14. Spin down tubes in mini centrifuge and place back on magnet
15. Go back to each sample with a p20 or p10 and remove any residual ethanol
16. Let the bead pellet dry 2-3 min - watch to see the pellet go from shiny to waxy looking. If it becomes light brown and cracked you have dried it too much
17. Close the lids of individual samples at this time to avoid over-drying beads if needed
18. Resuspend each bead pellet off magnet with 21ul of room temperature Low EDTA TE buffer
    1. This may be difficult because of the large amount of beads, pipette up and down many times
    2. You will see beads sticking to the outside of the pipette tip and to the sides of the tube, do your best to get much of the beads in solution but some just won't
    3. Spin down and gently flick tubes with lids closed if this helps
19. Place resuspended samples on the orbital mixer at 300rpm for 5 minutes, if no mixer is available leave at room temperature on the bench for 5 minutes
20. Place samples back on the magnet and wait for the solution to become clear
21. Slowly pipette up 20ul of the clear-ish supernatant and add it back into the tube to help make sure all the beads in solution get to the magnet. Make sure you don't pipette the bead pellet during this
22. Remove 20ul from each tube into fresh labeled strip tubes and place samples on ice, discard old tubes

## Ligation

1. Thaw needed reagents on ice:
   1. Buffer B1 (this should smell)
   2. Reagent B2
   3. Enzyme B3
2. **Flick** to mix reagents above a-c and spin down (ligase enzyme is sensitive to vortexing)
3. Keep Low EDTA TE buffer on ice as well
4. Prepare Ligation Master Mix in a 1.5mL tube on ice. Each component already includes 5% extra to account for error during pipetting. Add components in order to the tube:
   1. 4.2ul Low EDTA TE buffer \* n =
   2. 4.2ul Buffer B1 \* n =
   3. 10.5ul Reagent B2 \* n =
5. If you are making the Ligation Master Mix ahead of time **do not** add Enzyme B3 until directly before use
6. Start a thermocycler to the following program so it can pre-heat. If the previously used thermocycler lid is still hot, use a different thermocycler if one is available. If there is not a second thermocycler, use a bag of ice to cool the lid to room temperature
   1. Hold at 25C
   2. 15 minutes at 25C
   3. Hold at 4C
   4. Note: lid heating **set to OFF**
7. Add Enzyme B3 to the Ligation Master Mix on ice:
   1. 2.1ul \* n =
8. Pipette mix the master mix with 50% volume 10X (for example for 100ul of mix use 50ul to pipette mix) or invert until no swirling is visible and then spin master mix down (invert works well if doing 24+ samples)
9. Add 20ul of Ligation Master Mix to each sample tube from the post-extension cleanup and pipette mix 10X
10. Spin down sample tubes
11. Place samples in the thermocycler and press "skip step" to advance the ligation program

## Post-Ligation Cleanup

1. **Note this bead clean uses different ratios than the xGen low input DNA kit protocol to account for DNA fragments below 200bp**
2. Warm SPRI beads to room temperature in a drawer/away from light if not warmed already and swirl them gently to resuspend the beads
3. Make sure you still have fresh 80% ethanol
4. Take samples out of the thermocycler and place them at room temp on the workbench, the volume inside each tube should be 40ul
5. Add 64ul of SPRI beads to each sample (1.6X) and pipette mix at least 10X)
6. Place samples on an orbital mixer shaking at 300rpm for 10 minutes, or if no mixer is available leave at room temperature on the bench for 10 minutes
7. Place samples on the magnet rack and let the beads bind to the magnet
8. Remove supernatant without disturbing the beads (95ul)
9. Add 150ul fresh 80% ethanol to each tube without disturbing the beads
10. Remove supernatant from each tube without disturbing the beads
11. Add 150ul fresh 80% ethanol to each tube without disturbing the beads
12. Remove supernatant from each tube without disturbing the beads (160ul)
13. Spin down tubes in mini centrifuge and place back on magnet
14. Go back to each sample with a p20 or p10 and remove any residual ethanol
15. Let the bead pellet dry 2-3 min - watch to see the pellet go from shiny to waxy looking. If it becomes light brown and cracked you have dried it too much
16. Close the lids of individual samples at this time to avoid over-drying beads if needed
17. Immediately resuspend each bead pellet off magnet with 21ul of room temperature Low EDTA TE buffer
18. Place resuspended samples on the orbital mixer at 300rpm for 5 minutes, if no mixer is available leave at room temperature on the bench for 5 minutes
19. Place samples back on the magnet and wait for the solution to become clear
20. Remove 20ul from each tube into fresh labeled strip tubes and place samples on ice, discard old tubes

## Index Amplification

1. Thaw index plate needed on ice
2. Keep Low EDTA TE buffer on ice as well
3. Thaw needed reagents on ice:
   1. Reagent W2 P
   2. Buffer W3 P
   3. Enzyme W4 P
4. Vortex and spin down reagents a-c above and keep on ice, do not vortex the index plate but do spin it down
5. Prepare the Indexing PCR Master Mix in a 1.5mL tube on ice. Each component already includes 5% extra to account for error during pipetting. Add components in order to the tube:
   1. 10.5ul Low EDTA TE \* n =
   2. 4.2ul Reagent W2 P \* n =
   3. 10.5ul Buffer W3 P \*n =
6. If you are making the Indexing PCR Master Mix ahead of time **do not** add Enzyme W4 until directly before use
7. Samples should be on ice after post-ligation cleanup
8. Add 5ul of the **planned index pair** to each sample (see index planning above for details)
   1. It is essential that this happens according to your plan otherwise samples will not be distinguishable after sequencing
9. Add Enzyme W4 P to the Indexing PCR Master Mix on ice:
   1. 1.05ul \* n =
10. Vortex and spin down the Indexing PCR Master Mix and keep on ice
11. Add 25ul of Indexing PCR Master Mix to each sample tube
12. Vortex and spin down sample tubes
13. Determine cycling conditions: samples are cycled a different number of times based on the input amount of DNA used
    1. 250ng input 5 cycles
    2. 100ng input 6 cycles
    3. 10ng input 9 cycles
    4. 1ng input 12 cycles
    5. 0.1ng input 16 cycles
14. Place samples in the thermocycler and run the following indexing PCR program (adjust number of cycles to repeat steps i. – iii.):
    1. Lid temperature set to 105C
    2. Volume set to 50ul
    3. 98C for 30 seconds
       1. 98C for 10 seconds
       2. 60C for 30 seconds
       3. 68C for 60 seconds
    4. 4C hold
15. After the program is done keep samples at room temp for post-indexing PCR cleanup

## Post-Indexing Cleanup 1

1. **Note this bead clean uses different ratios than the xGen low input DNA kit protocol to account for DNA fragments below 200bp**
2. Warm SPRI beads to room temperature in a drawer/away from light if not warmed already and swirl them gently to resuspend the beads
3. Make sure you still have fresh 80% ethanol
4. Take samples out of the thermocycler and place them at room temp on the workbench, the volume inside each tube should be 50ul
5. Add 80ul of SPRI beads to each sample (1.6X) and pipette mix at least 10X)
6. Place samples on an orbital mixer shaking at 300rpm for 10 minutes, or if no mixer is available leave at room temperature on the bench for 10 minutes
7. Place samples on the magnet rack and let the beads bind to the magnet
8. Remove supernatant without disturbing the beads (120ul)
9. Add 150ul fresh 80% ethanol to each tube without disturbing the beads
10. Remove supernatant from each tube without disturbing the beads
11. Add 150ul fresh 80% ethanol to each tube without disturbing the beads
12. Remove supernatant from each tube without disturbing the beads
13. Spin down tubes in mini centrifuge and place back on magnet
14. Go back to each sample with a p20 or p10 and remove any residual ethanol
15. Let the bead pellet dry 2-3 min - watch to see the pellet go from shiny to waxy looking. If it becomes light brown and cracked you have dried it too much
16. Close the lids of individual samples at this time to avoid over-drying beads if needed
17. Immediately resuspend each bead pellet off magnet with 31ul of room temperature Low EDTA TE buffer
18. Place resuspended samples on the orbital mixer at 300rpm for 5 minutes, if no mixer is available leave at room temperature on the bench for 5 minutes
19. Place samples back on the magnet and wait for the solution to become clear
20. Remove 30ul from each tube into fresh labeled strip tubes and place samples on ice, discard old tubes

## Post-Indexing Cleanup 2

1. **Note this bead clean uses different ratios than the xGen low input DNA kit protocol to account for DNA fragments below 200bp**
2. Warm SPRI beads to room temperature in a drawer/away from light if not warmed already and swirl them gently to resuspend the beads
3. Make sure you still have fresh 80% ethanol
4. Samples should be 30ul from the previous bead clean
5. Add 48ul of SPRI beads to each sample (1.6X) and pipette mix at least 10X
6. Place samples on an orbital mixer shaking at 300rpm for 10 minutes, or if no mixer is available leave at room temperature on the bench for 10 minutes
7. Place samples on the magnet rack and let the beads bind to the magnet
8. Remove supernatant without disturbing the beads (70ul)
9. Add 150ul fresh 80% ethanol to each tube without disturbing the beads
10. Remove supernatant from each tube without disturbing the beads
11. Add 150ul fresh 80% ethanol to each tube without disturbing the beads
12. Remove supernatant from each tube without disturbing the beads
13. Spin down tubes in mini centrifuge and place back on magnet
14. Go back to each sample with a p20 or p10 and remove any residual ethanol
15. Let the bead pellet dry 2-3 min - watch to see the pellet go from shiny to waxy looking. If it becomes light brown and cracked you have dried it too much
16. Close the lids of individual samples at this time to avoid over-drying beads if needed
17. Resuspend each bead pellet off magnet with 21ul of room temperature Low EDTA TE buffer
18. Place the resuspended samples on the orbital mixer at 300rpm for 5 minutes, if no mixer is available leave at room temperature on the bench for 5 minutes
19. Place samples back on the magnet and wait for the solution to become clear
20. Remove 20ul from each tube into fresh labeled strip tubes and place samples on ice, discard old tubes
21. Libraries are finished and can now be safely stored at -20C or moved on to QC directly. If doing QC immediately place on ice

Proceed to using a dsDNA Qubit to quantify the libraries and either a Bioanalyzer or TapeStation to determine library size. Pool samples equal-molarly by using concentration and library size to determine each library's nM concentration. Before pooling, determine how many samples will be sequenced in each lane to achieve desired coverage. **With degraded samples it is advised to sequence with a 2 x 100bp flow cell** because of the limitations of the insert size of the original DNA. Sequencing with 150bp will likely cause read-through into the adapters and flow cell oligos during sequencing and can lead to low quality reads.