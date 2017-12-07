//these two chunnks of code can just be copied and pasted where the old code existed.
//do need to add images to assests folder for wood UIImage to work properly

    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }

    // for constructing tower, adds block with physics and variable length / width
    func addBlockToScene(name: String, position: SCNVector3, length: CGFloat, width: CGFloat) -> Void {

        let randomNum = randomNumbers(firstNum: 0, secondNum: 3)
        print(Double(randomNum))

        var wood = #imageLiteral(resourceName: "wood1")

        if randomNum > 2 {
        wood = #imageLiteral(resourceName: "wood1")
        } else if randomNum < 1 {
        wood = #imageLiteral(resourceName: "wood2")
        } else {
        wood = #imageLiteral(resourceName: "wood3")
        }

        // set up geometry size and color
        let cube = SCNBox(width: width, height: 0.02, length: length, chamferRadius: 0.001)

        let material = SCNMaterial()
        material.diffuse.contents = wood
        material.specular.contents = UIColor.white
        cube.materials = [material]

***************************************************************************************************

        // replace material on node to be activated to be red
        let selectedMaterial = SCNMaterial()
        selectedMaterial.diffuse.contents = #imageLiteral(resourceName: "redWood1")
        selectedMaterial.specular.contents = UIColor.white

        newSelectedBlock.geometry?.materials = [selectedMaterial]

        selectedBlock = newSelectedBlock
    }

    // set previously active block back to blue
    func deselectBlock() -> Void {
        guard selectedBlock != nil else {
            return
        }

        let unselectedMaterial = SCNMaterial()
        unselectedMaterial.diffuse.contents = #imageLiteral(resourceName: "wood1")
        unselectedMaterial.specular.contents = UIColor.white
        selectedBlock!.geometry?.materials = [unselectedMaterial]
        selectedBlock = nil
    }
